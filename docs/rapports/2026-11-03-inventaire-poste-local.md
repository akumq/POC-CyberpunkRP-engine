# Inventaire du poste de test local

| | |
| --- | --- |
| Date | 2026-11-03 |
| Jalon | M0 / M1 — étape 1 |
| Actions sur le jeu | Aucune (lecture seule) |

## Environnement

| Élément | Valeur |
| --- | --- |
| Distribution | EndeavourOS (Arch), noyau 7.1.5-arch1-2 |
| GPU | NVIDIA GeForce RTX 4070 (AD104) |
| Pilote | NVIDIA 610.43.03 |
| Docker | 29.7.1 |
| Espace libre | 413 Go |

## Jeu

| Élément | Valeur |
| --- | --- |
| Bibliothèque Steam | `~/.local/share/Steam` (unique, via `libraryfolders.vdf`) |
| Dossier du jeu | `steamapps/common/Cyberpunk 2077` (83 Go) |
| Version | **2.5** — `ProductVersion` 2.5, `FileVersion` 3.0.5813403, P4CL 13555055 |
| Build Steam | 26161058 |
| Préfixe Proton | `steamapps/compatdata/1091500` |
| Proton | Proton Experimental (`experimental-11.0-20261027b`), préfixe en 11.0-100 ; aucun outil forcé pour ce jeu |
| Options de lancement Steam | aucune |
| Runtime VC++ du préfixe | `msvcp140.dll` 14.28.29334 (VS 2019) : trop ancien pour RED4ext, risque d'« error 998 » |

## Mods présents

Aucun. Le jeu est vanilla :

- `red4ext/`, `bin/x64/plugins/`, `r6/scripts/`, `r6/tweaks/`, `archive/pc/mod/` : absents ;
- `mods/` : vide (seulement `.stub`) ;
- aucun chargeur dans `bin/x64/` (`winmm.dll`, `version.dll`, `global.ini`).

## Sauvegardes du joueur

`pfx/drive_c/users/steamuser/Saved Games/CD Projekt Red/Cyberpunk 2077` : 608 Mo (sauvegardes auto et manuelles).

## Remarques

- Un rapport de plantage du 2026-11-01 existe dans `bin/x64/` (`EXCEPTION_ACCESS_VIOLATION` après 77 min de jeu, sans mod). À garder en tête pour ne pas l'attribuer au moteur plus tard.
- Le jeu est déjà en 2.5 : la cible de M1 correspond exactement à la version installée.

## Prochaine étape

Sauvegarde (étape 2) : archiver `bin/`, `r6/`, `engine/config` et les sauvegardes du joueur avant toute modification. `red4ext/` et `archive/pc/mod/` n'existent pas, rien à archiver pour eux.
