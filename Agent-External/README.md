# Agent-External — knowledge base condivisa per agent esterni

Questa cartella è l'UNICA scrivibile via il server MCP del vault (`vault-mcp`).
Gli agent esterni (es. un altro Claude) possono creare/aggiornare note QUI dentro
per contribuire alla knowledge base. Il resto del vault resta in sola lettura.

- Scrivere solo file `.md`/`.txt`.
- Una nota = un argomento; usare frontmatter se utile.
- Le altre cartelle (wiki/, Agent-Claude/, raw/) NON sono scrivibili dall'esterno.
