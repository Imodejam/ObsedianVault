# Working context

## Ora
Puntify Social Skin — fase creativa/demo.
- Stefano: "Proviamo" (demo post stile Taffo) + scarica più campagne KiRweb.
- FATTO: demo post servizio Cassa ("Il tuo incasso di marzo era questo" / scontrino accartocciato dark + logo Puntify bianco reale). Salvato in /home/progetti/puntify-social/posts/2026-07-16_cassa-scontrino/ (image.jpg + base + meta.json con metatag). Inviato a Stefano (Telegram 6435/6436) per approvazione.
- IN CORSO: subagent a8a7edeac22bcd485 scarica + analizza altre campagne KiRweb in research/kirweb/.

## Prossimi passi
- Ricevere approvazione/feedback Stefano sul demo (approva/rigenera/cambia copy).
- Integrare EXTRA_PRINCIPLES.md KiRweb nel knowledge quando il subagent finisce.
- Se OK: costruire la skin giornaliera completa (rotazione topic -> copy Taffo -> gpt-image-2 edits+logo -> approvazione NemiBot inline -> Buffer 3 canali best time).

## Pipeline validata
gpt-image-2 (scena senza testo) -> PIL compositing (headline Liberation Sans Bold + accento rosso #B80000 + logo bianco reale) -> approvazione -> Buffer.
Standard immagine approvato ("perfetta"): logo VERO compositato, mai disegnato dall'AI.
