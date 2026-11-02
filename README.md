# POC-CyberpunkRP-engine

Fork public de [CyberpunkMP](https://github.com/tiltedphoques/CyberpunkMP), le moteur multijoueur pour Cyberpunk 2077 créé par **Tilted Phoques SRL**.

> **Statut : preuve de concept.** Le moteur d'origine cible le patch 2.2 du jeu et ne démarre plus sur les versions actuelles. Le premier chantier de ce fork est son portage.

Ce dépôt est le moteur du projet POC-CyberpunkRP, un serveur de roleplay francophone. Il contient **uniquement** les modifications du moteur, publiées comme l'exige sa licence. Le reste du projet (backend, plugins, launcher, voix) vit dans un dépôt séparé et utilise ce moteur à travers ses releases et son SDK.

## Ce que fait CyberpunkMP

D'après sa documentation d'origine :

- synchronisation de l'apparence, de l'équipement, des déplacements et des animations de base des joueurs ;
- synchronisation complète des véhicules et de leurs passagers ;
- SDK .NET pour écrire des plugins côté serveur, SDK Redscript pour les plugins côté client ;
- appels de procédure distants (RPC) automatiques entre plugins client et serveur ;
- serveur dédié, utilisable en Docker.

## Ce que ce fork ajoute

Voir la [feuille de route](docs/ROADMAP.md) et le [cahier des charges du moteur](docs/fonctionnel/cahier-des-charges.md). En priorité :

1. portage sur le patch 2.5 de Cyberpunk 2077 ;
2. limitation de débit réseau côté serveur ;
3. extension du SDK serveur pour les besoins d'un serveur RP ;
4. évaluation de la synchronisation du combat, des PNJ et des objets du monde ;
5. releases automatisées : binaires client, serveur et SDK.

## Construire

Prérequis du projet d'origine :

- [Visual Studio 2022](https://visualstudio.microsoft.com/downloads/) (sur Windows, SDK Windows inférieur à 10.0.26100.0)
- [xmake](https://github.com/xmake-io/xmake/releases)
- [git](https://git-scm.com/downloads)

```sh
git submodule update --init
xmake -y
```

Serveur en Docker :

```sh
docker build . -t cyberpunkmp
docker run -p 11778:11778 -v $(pwd)/config:/app/config -v $(pwd)/plugins:/app/plugins cyberpunkmp
```

Côté joueur, le moteur s'appuie sur [RED4ext](https://github.com/WopsS/RED4ext), [Cyber Engine Tweaks](https://github.com/maximegmd/CyberEngineTweaks), [redscript](https://github.com/jac3km4/redscript), [ArchiveXL](https://github.com/psiberx/cp2077-archive-xl), [TweakXL](https://github.com/psiberx/cp2077-tweak-xl), [Codeware](https://github.com/psiberx/cp2077-codeware) et [Input Loader](https://github.com/jackhumbert/cyberpunk2077-input-loader). Les versions exactes compatibles seront fixées par le portage.

## Contribuer

- Une modification par pull request, décrite et testée.
- Ce dépôt ne contient aucune logique métier de serveur RP : elle appartient aux plugins.
- Les contributions sont publiées sous la licence ci-dessous.

## Licence et attribution

Distribué sous la [licence CyberpunkMP](LICENSE.md) de **Tilted Phoques SRL**, créateur du logiciel d'origine. Ce n'est pas une licence open source :

- toute modification doit rester publique, sous les mêmes termes, avec attribution à Tilted Phoques SRL ;
- la distribution se fait uniquement via GitHub ou le site du projet, jamais sur une plateforme de mods ;
- les composants `EmoteSystem`, `JobSystem` et les plugins Redscript d'exemple sont sous licence MIT.

Projet de fan non officiel, sans lien avec CD PROJEKT RED ni avec Tilted Phoques. Cyberpunk 2077 est une marque de CD PROJEKT S.A. Jouer exige une copie légale du jeu.
