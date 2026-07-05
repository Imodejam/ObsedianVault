# Brief per Claude Code — Login Google/Apple integrata nell'app iOS (niente Chrome esterno)

## Contesto
L'app iOS Puntify è un wrapper nativo **SwiftUI + WKWebView** che carica la web app **Blazor WASM** (`Puntify.App`). Il lato NATIVO dell'OAuth è **già specificato** (vedi `prompt-app-puntify-xcode.md`, §3-bis): usa `ASWebAuthenticationSession` con scheme custom `it.puntify.app`, message handler `puntifyNative`, e reinietta i token chiamando `window.onNativeOAuthTokens`.

**Questo brief riguarda SOLO le modifiche al lato WEB (Blazor `Puntify.App`)** che devono combaciare con quel protocollo. Devono essere ESATTE nei nomi (scheme, handler, funzioni), altrimenti il login non ritorna nell'app.

## Problema attuale
Oggi il click su "Continua con Google" fa:
1. `Login.razor` → `SignInWithGoogle()` → `Supabase.GetGoogleSignInUrl()` (URL Supabase authorize con `redirect_to = {baseUrl}/auth/callback`, flow implicito → token nel fragment `#access_token=...`).
2. `JSRuntime.InvokeVoidAsync("redirectTo", url)` → `window.redirectTo` in `index.html` fa `window.location.href = url`.

Dentro la WKWebView questo naviga verso `accounts.google.com` → iOS **apre Chrome/Safari esterno** e Google rifiuta l'OAuth nelle webview embedded (`disallowed_useragent`). La sessione resta nel browser esterno e l'app non la riceve.

## Obiettivo
Quando l'app nativa è presente (`window.PuntifyNative?.oauth === true`), il login Google **E** Apple NON deve navigare via `window.location`: deve passare l'URL al nativo, che apre `ASWebAuthenticationSession` (scheda sicura in-app), e al ritorno reinietta i token nella web app. Fuori dall'app nativa (browser desktop/PWA) il comportamento attuale resta invariato.

## Protocollo (contratto col nativo — NON cambiare i nomi)
- Rilevamento nativo: `window.PuntifyNative && window.PuntifyNative.oauth === true` (settato dall'app nativa all'avvio).
- Scheme redirect custom: **`it.puntify.app://auth-callback`**.
- Invio al nativo: `window.webkit.messageHandlers.puntifyNative.postMessage({ action: "oauth", provider: "google"|"apple", url: "<authorizeUrl>" })`.
- Ritorno dal nativo: il nativo chiama **`window.onNativeOAuthTokens("<fragment>")`** dove `<fragment>` è la parte dopo `#` della callback (es. `access_token=...&refresh_token=...&expires_in=...`).

## Modifiche richieste (Blazor `Puntify.App`)

### 1. `Services/SupabaseService.cs` — redirect_to condizionale
`GetGoogleSignInUrl()` e `SignInWithApple()`/`GetAppleSignInUrl()` costruiscono `SignInOptions.RedirectTo`. Aggiungere un parametro per usare lo scheme nativo:

```csharp
public async Task<string?> GetGoogleSignInUrl(bool nativeApp = false)
{
    await EnsureInitialized();
    var redirect = nativeApp
        ? "it.puntify.app://auth-callback"
        : $"{GetBaseUrl()}/auth/callback";
    var options = new SignInOptions { RedirectTo = redirect };
    var providerAuth = await _client.Auth.SignIn(Supabase.Gotrue.Constants.Provider.Google, options);
    return providerAuth?.Uri.ToString();
}
```
Fare lo stesso per Apple. Mantenere il **flow implicito** (token nel fragment): il nativo e `authHelper.getTokenFromUrl` leggono i token dall'hash.

### 2. `Pages/Shared/Login.razor` — instradare al nativo
In `SignInWithGoogle()` (e nell'equivalente Apple), diramare in base alla presenza dell'app nativa:

```csharp
private async Task SignInWithGoogle()
{
    _busy = true; _error = null;
    try
    {
        var isNative = await JSRuntime.InvokeAsync<bool>("puntifyNativeAuth.isNative");
        var url = await Supabase.GetGoogleSignInUrl(nativeApp: isNative);
        if (string.IsNullOrEmpty(url)) { _error = L["login_err_no_auth_url"]; _busy = false; return; }

        if (isNative)
            await JSRuntime.InvokeVoidAsync("puntifyNativeAuth.start", "google", url); // apre ASWebAuthenticationSession via nativo
        else
            await JSRuntime.InvokeVoidAsync("redirectTo", url);                         // browser: comportamento attuale
    }
    catch (Exception ex) { _error = string.Format(L["login_err_generic"], ex.Message); _busy = false; }
}
```

### 3. Nuovo JS `wwwroot/js/native-auth.js` (incluso in `index.html`)
```js
window.puntifyNativeAuth = {
  isNative: function () {
    return !!(window.PuntifyNative && window.PuntifyNative.oauth === true
           && window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.puntifyNative);
  },
  // Passa l'URL OAuth al nativo, che apre ASWebAuthenticationSession
  start: function (provider, url) {
    window.webkit.messageHandlers.puntifyNative.postMessage({ action: "oauth", provider: provider, url: url });
  }
};
// Il nativo chiama questa funzione al ritorno del login con il fragment della callback
window.onNativeOAuthTokens = function (fragment) {
  var f = (fragment || "").replace(/^#/, "");
  // Riusa TUTTA la logica esistente di /auth/callback (SetSession + creazione account + routing per ruolo)
  window.location.href = "/auth/callback#" + f;
};
```
> `AuthCallback.razor` (`/auth/callback`) legge già i token con `authHelper.getTokenFromUrl` (dall'hash) e fa `Supabase.SetSession(...)`, crea/aggiorna l'account e instrada per ruolo. Reindirizzando a `/auth/callback#<fragment>` si riusa tutto senza duplicare logica.

### 4. (Opzionale) `window.PuntifyNative`
Non va settato dalla web app: lo inietta l'app nativa. La web app lo LEGGE soltanto. In assenza (browser/PWA) `isNative` = false → flusso attuale.

## Modifica lato server (NON del dev — la fa Stefano/ops)
Aggiungere **`it.puntify.app://auth-callback`** alla allow-list Supabase GoTrue `additional_redirect_urls` (altrimenti Supabase rifiuta il redirect verso lo scheme). Da fare su Collaudo e Prod. **Non applicare in prod senza OK.**

## Criteri di accettazione
- In app nativa: click su "Continua con Google" → si apre la **scheda in-app** (ASWebAuthenticationSession), **non** Chrome/Safari esterno. Dopo il login si torna nell'app già autenticati (sessione Supabase valida, routing per ruolo corretto).
- Idem per Apple.
- In browser desktop e PWA (no app nativa): comportamento invariato (redirect classico).
- Nessuna regressione su login email/password.
- I nomi del protocollo combaciano ESATTAMENTE col nativo: scheme `it.puntify.app://auth-callback`, handler `puntifyNative`, azione `oauth`, funzione `window.onNativeOAuthTokens`.

## Alternativa (più nativa, più setup) — opzionale
In alternativa ad ASWebAuthenticationSession si può usare il **Google Sign-In SDK nativo (GIDSignIn)**: selettore account iOS nativo → `idToken` → Supabase `SignInWithIdToken(Provider.Google, idToken, nonce)`. UX migliore ma richiede `GoogleService-Info.plist`, un OAuth client iOS su Google Cloud e più codice nativo. Consigliata solo se si vuole il massimo dell'integrazione; per ora ASWebAuthenticationSession riusa il flusso Supabase esistente ed è sufficiente.
