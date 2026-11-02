# Instructions pour Claude Code — POC-CyberpunkRP-engine

Tu travailles sur le **moteur** du projet POC-CyberpunkRP, un serveur de roleplay Cyberpunk 2077 francophone. Ce dépôt est un fork public de `tiltedphoques/CyberpunkMP`. Le reste du projet (backend Spring, adaptateur C#, launcher, voix) est dans le dépôt privé `akumq/POC-CyberpunkRP`, qui référence ce moteur en sous-module `engine/`.

Lis d'abord [README.md](README.md), [docs/ROADMAP.md](docs/ROADMAP.md) et [docs/fonctionnel/cahier-des-charges.md](docs/fonctionnel/cahier-des-charges.md).

Le porteur du projet est Amadou (GitHub `akumq`). Il écrit en français, de façon directe : réponds en français, court et concret.

## Où tu tournes

Sur le PC d'Amadou, une machine **Linux**, où Cyberpunk 2077 est installé et se lance via **Steam et Proton**. Tu as donc accès au vrai jeu, ce qu'aucune session dans le cloud n'a.

## Mission actuelle : jalons M0 et M1

Dans l'ordre. Arrête-toi et rends compte à chaque étape marquée ⏸.

1. **Inventaire, sans rien modifier.**
   - Trouver le dossier du jeu (`steamapps/common/Cyberpunk 2077`, via `libraryfolders.vdf`) et son préfixe Proton (`steamapps/compatdata/1091500`).
   - Relever la version du jeu, la version de Proton utilisée, et les mods déjà présents (`red4ext/`, `bin/x64/plugins/`, `r6/scripts/`, `archive/pc/mod/`).
   - Relever la distribution, le GPU et son pilote.
   - ⏸ Rendre compte avant d'aller plus loin.
2. **Sauvegarde.** Avant toute modification du jeu : archiver `bin/`, `red4ext/`, `r6/`, `archive/pc/mod/` et les sauvegardes du joueur (dans le préfixe Proton, `drive_c/users/steamuser/Saved Games/CD Projekt Red/Cyberpunk 2077`). Indiquer où est l'archive.
3. **Build du serveur sous Linux** (M0). Construire l'image Docker du serveur depuis ce dépôt. Noter précisément ce qui casse.
4. **Build de la DLL client** (M0). Elle se compile sous Windows (Visual Studio 2022 + xmake). Ne tente pas de compilation croisée longue : propose plutôt un workflow GitHub Actions `windows-latest` qui produit la DLL en artefact, dans une PR.
5. **Test du moteur d'origine sur le jeu** (M1).
   - Installer les frameworks requis dans les versions compatibles avec la version du jeu (RED4ext, redscript, ArchiveXL, TweakXL, Codeware, Cyber Engine Tweaks, Input Loader), depuis leurs releases GitHub officielles uniquement.
   - Sous Proton, RED4ext échoue avec « error 998 » si le préfixe contient un vieux runtime Visual C++ : installer le runtime Visual C++ 2022 dans le préfixe, et ajouter l'option de lancement Steam `WINEDLLOVERRIDES="winmm,version=n,b" %command%`.
   - Lancer le jeu avec le moteur. Il cible le patch 2.2 et ne démarrera probablement pas sur la version actuelle : l'objectif est de **capturer l'erreur exacte** (logs dans `red4ext/logs/`, sortie Proton avec `PROTON_LOG=1`).
   - ⏸ Rendre compte avec les logs.
6. **Portage** : seulement après accord d'Amadou. Point de départ : comparer avec les forks qui ont déjà porté le moteur, [MrYar07/CyberpunkMP](https://github.com/MrYar07/CyberpunkMP) (patch 2.5) et [Night City Online](https://github.com/ofmiceandcam98-eng/CyberpunkMP) (patch 2.31). Leur code peut être repris ici, même licence, en créditant leurs auteurs dans le message de commit.

## Règles

- **Le jeu d'Amadou est précieux.** Aucune modification sans sauvegarde préalable. Ne jamais supprimer ses sauvegardes. Demande avant toute action sur le dossier du jeu ou le préfixe Proton, et n'installe rien depuis une source autre que les releases officielles.
- **Pull requests uniquement vers ce fork.** Une fois pour toutes : `gh repo set-default akumq/POC-CyberpunkRP-engine`. Sans ça, `gh pr create` vise `tiltedphoques/CyberpunkMP`. Ne jamais ouvrir de PR, d'issue ni de commentaire sur le dépôt d'origine, et ne pas mentionner ses issues (`tiltedphoques/CyberpunkMP#…`), ce qui créerait des liens visibles chez eux.
- **Une branche et une PR par tâche**, liée à son milestone (M0 à M5). Pas de push direct sur `main`.
- **Licence CyberpunkMP** : tout ce qui est dans ce dépôt est public. N'y mets aucune logique métier RP, aucun secret, aucun code du dépôt privé.
- **Rapports** : chaque étape ⏸ donne un fichier `docs/rapports/AAAA-MM-JJ-<sujet>.md` (environnement, ce qui a été fait, logs utiles, prochaine étape proposée), livré dans une PR. Quand les issues du dépôt seront activées, rattache-les à l'issue du milestone.
- **Commits** en français, au format `type: description` (`docs:`, `build:`, `fix:`, `feat:`).

## Contexte utile

- Le moteur synchronise apparence, équipement, déplacements, animations de base et véhicules. Le combat, les PNJ et les objets du monde ne sont probablement pas synchronisés (évaluation prévue en M5).
- Le serveur héberge des plugins .NET. L'adaptateur RP du projet privé en sera un, et il devra fonctionner **sans modifier le moteur** : c'est l'objet de M3.
- Une autre session Claude, dans le cloud, travaille en parallèle sur le dépôt privé (backend et simulateur de jeu). La coordination passe par les PR et la doc, pas par des messages directs.
