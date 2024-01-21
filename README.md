# Lua (Scribunto) Modules for Wikimedia projects

This repository is just a lazy way for me to keep track of the Lua modules I'm developing for Wikimedia projects.
Please refer to the documentation and source code of each module on the Wikimedia projects for more information.

The repo is there just for me to take advantage of the github / IDE tooling, being the visual editor on Wikimedia projects 
quite limited at the moment.

You can query the Lua Modules on every Wikimedia project by using the following URL:

```
https://<lang>.<project>.org/w/index.php?title=Special:AllPages&namespace=828```
```

Where `<lang>` is the language code of the project and `<project>` is the project code.
So for [Italian Wikivoyage](https://it.wikivoyage.org) you would use `it.wikivoyage`.

`828` is the namespace number for Lua modules.

**Examples (Italian projects)**:

- [Moduli su it.voy](https://it.wikivoyage.org/w/index.php?title=Special:AllPages&namespace=828)
- [Moduli su it.wikisource](https://it.wikisource.org/w/index.php?title=Special:AllPages&namespace=828)
- [Moduli su it.wiktionary](https://it.wiktionary.org/w/index.php?title=Special:AllPages&namespace=828)
- [Moduli su it.wikibooks](https://it.wikibooks.org/w/index.php?title=Special:AllPages&namespace=828)
- [Moduli su it.wikinews](https://it.wikinews.org/w/index.php?title=Special:AllPages&namespace=828)
- [Moduli su it.wikiquote](https://it.wikiquote.org/w/index.php?title=Special:AllPages&namespace=828)
- [Moduli su it.wikipedia](https://it.wikipedia.org/w/index.php?title=Special:AllPages&namespace=828)

## Structure

At the moment, they're simply organized by project, plus a `sandbox` folder for testing purposes.


## Resources about Lua Modules on Wikimedia projects

- [mw:Extension:Scribunto/Lua reference manual](https://www.mediawiki.org/wiki/Extension:Scribunto)
- [Wikidata Help:Lua](https://www.wikidata.org/wiki/Help:Lua)
- [Wikibase technical docs](https://doc.wikimedia.org/Wikibase/master/php/docs_topics_lua.html#mw_wikibase_getEntityIdForCurrentPage)
- [WikiTech Homepage](https://wikitech.wikimedia.org/wiki/Main_Page)