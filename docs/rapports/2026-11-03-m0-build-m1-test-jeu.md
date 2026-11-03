# M0 : builds — M1 : premier test du moteur sur le patch 2.5

| | |
| --- | --- |
| Date | 2026-11-03 |
| Jalons | M0 (étapes 2 à 4), M1 (étape 5) |
| Poste | EndeavourOS, RTX 4070 (pilote 610.43.03), Proton Experimental 11, jeu 2.5 (build Steam 26161058) — voir [l'inventaire](2026-11-03-inventaire-poste-local.md) |

## Résumé

- **Serveur Docker** : cassé à l'origine, réparé (PR #3). L'image se construit et le serveur démarre.
- **DLL client** : nouvelle CI `windows-2022` verte, qui produit le dossier `mod/` complet en artefact (PR #2).
- **Frameworks 2.5** : installés, le jeu atteint le menu principal sans erreur.
- **Moteur sur le 2.5** : la DLL compilée depuis ce dépôt **plante au chargement**. Cause identifiée : la structure `Callback` du moteur a grandi en 2.5 et le RED4ext.SDK embarqué date de 2024.

## Étape 2 — Sauvegarde

`~/Backups/cyberpunk2077-2026-11-03.tar.zst` (781 Mo, 785 fichiers, SHA-256 à côté) : `bin/`, `r6/`, `engine/config`, les sauvegardes du joueur et `AppData/Local/CD Projekt Red/Cyberpunk 2077`. Le fichier `localconfig.vdf` de Steam est sauvegardé avant la modification des options de lancement.

## Étape 3 — Image Docker du serveur

Le `docker build` d'origine échoue pour trois raisons :

1. `git` et `unzip` absents de l'image : xmake ne peut ni cloner ni extraire les paquets.
2. Les dépendances non versionnées sont résolues sur les versions de 2026, car `package.requires_lock` est désactivé et le lock ne couvre que Windows. entt 4.0 exige CMake 3.28 (Debian 12 fournit la 3.25), abseil 20260107 et cryptopp 8.9 ne compilent plus, abseil entre en conflit avec GameNetworkingSockets.
3. La cible `Admin` appelle `pnpm`.

Correctif : outils ajoutés, `xmake-repo` figé au commit `fe18a6c` (2024-11-21, date du lock), `build-artifacts` cloné et fichiers `updated` créés. Sans ces fichiers, xmake remet les dépôts à jour au premier `xmake f`. Le commit indiqué dans le lock (`a815ba4`, juin 2024) est trop ancien : il ne connaît pas mimalloc 2.1.7.

Résultat : build complet en environ 3 min. Le serveur écoute en UDP et TCP sur 11778 et charge JobSystem et EmoteSystem. À noter :

- sans `CYBERPUNKMP_ADMIN_USERNAME` et `CYBERPUNKMP_ADMIN_PASSWORD`, le serveur s'arrête (`SecurityException`) ;
- il tente de s'annoncer sur la liste de serveurs d'origine (`Server could not reach the server list!`). À couper pour un serveur privé.

Les CI d'origine `Build linux` et `Build windows` échouent pour la même raison (Windows : conflit abseil/GameNetworkingSockets en moins de 2 min).

## Étape 4 — CI de la DLL client

Workflow `.github/workflows/client-windows.yml` : runner `windows-2022` (VS 2022), même pinning xmake que le Dockerfile, `core.longpaths` et dossier xmake court (`C:/x`), sans quoi le clone de GameNetworkingSockets échoue sur des chemins trop longs. Il produit l'artefact `CyberpunkMP-client-<sha>` : DLL, PDB, `assets/` (redscript, archive, tweak, inputs), dans la structure de `red4ext/plugins/zzzCyberpunkMP`. Premier run : environ 16 min, puis cache.

## Étape 5 — Test sur le jeu

### Frameworks installés (releases GitHub officielles)

| Framework | Version | Note de version |
| --- | --- | --- |
| RED4ext | 1.31.0 | minimum patch 2.5 |
| redscript | 0.5.32 | bundles 2.5 |
| ArchiveXL | 1.28.6 | |
| TweakXL | 1.12.0 | compatibilité 2.5 |
| Codeware | 1.21.2 | |
| Cyber Engine Tweaks | 1.38.1 | |
| Input Loader | 0.2.6 | |

Dans le préfixe Proton, le runtime VC++ est passé de 14.28 à 14.44 (`protontricks 1091500 vcrun2022`). L'option de lancement Steam est `WINEDLLOVERRIDES="winmm,version=n,b" PROTON_LOG=1 %command%`. Aucun fichier du jeu écrasé, liste des 79 fichiers ajoutés conservée.

**Référence (frameworks seuls)** : RED4ext s'initialise (1 032 136 adresses), les 4 plugins se chargent, redscript compile, CET s'accroche, le menu principal du 2.5 s'affiche. Pas d'erreur 998.

### Essai 1 — release officielle v0.1 (2024-11-21)

```
[RED4ext] CyberpunkMP did not initialize properly, unloading...
```

Ce n'est pas un problème de patch : dans la v0.1, `Main` passe par une connexion au compte (`oobe::StartLogin`) et renvoie `false` hors du launcher Electron d'origine. Ce binaire ne permet pas de tester.

### Essai 2 — DLL compilée depuis ce dépôt (CI, commit `4e8bdff`)

Lancement : `-online -ip 127.0.0.1 -port 11778`, serveur Docker local actif. `Main` est appelé, le jeu se ferme aussitôt. Sortie Proton :

```
seh:dispatch_exception code=c0000005 (EXCEPTION_ACCESS_VIOLATION) addr=0000020000020140
  0000020000020140: unknown module.
  Cyberpunk2077.exe + 0x201802C
  Cyberpunk2077.exe + 0x2017C81
  CyberpunkMP.dll   + 0x1078A5   Support::RedLibProvider::OnBootstrap   RedLibProvider.cpp:6
  CyberpunkMP.dll   + 0x10259B   Core::Application::Bootstrap           Application.cpp:47
  CyberpunkMP.dll   + 0x1070E7   Main                                   Main.cpp:53
  RED4ext.dll       + 0x7DFA5 …
```

Reproductible à l'identique sur deux lancements. Symboles obtenus avec le PDB de la CI et `llvm-symbolizer`.

### Cause

`RedLibProvider::OnBootstrap` → `Red::TypeInfoRegistrar::RegisterDiscovered` → `CRTTISystem::Get()->AddRegisterCallback(&OnRegister)`. Le slot de vtable (0xC0) n'a pas changé, mais le paramètre `Callback` a changé de taille en 2.5 :

```diff
- constexpr size_t DefaultFixedCallbackBufferSize = 32;   // vendor/RED4ext.SDK (f52af6a, 2024-11-26)
+ constexpr size_t DefaultFixedCallbackBufferSize = 64;   // RED4ext.SDK 0f5eba42a « Add support for patch 2.5 »
```

Le jeu lit le pointeur du gestionnaire à l'offset 64, où notre DLL n'a rien écrit, et y saute. C'est le premier appel au moteur : d'autres écarts suivront forcément (types, offsets, RedLib).

## Prochaine étape proposée — portage (étape 6)

1. Mettre `vendor/RED4ext.SDK` sur un SDK 2.5. MrYar07 a publié le fork Tilted Phoques fusionné avec le SDK officiel 2.5 (branche `cpmp-2.5` de `MrYar07/RED4ext.SDK`).
2. Remplacer `code/client/Red` par la RedLib de Codeware 1.21.x et adapter le client à l'API plugin v1 de RED4ext, en suivant le commit `c96b8c54` de MrYar07/CyberpunkMP (« Port the client to Cyberpunk 2077 patch 2.5 »), puis ses correctifs en jeu (`6fc92e9e`).
3. Ne pas reprendre le code « campaign co-op », le tunnel Steam ni l'installeur, qui sont hors périmètre. Reprendre ensuite, un par un, les correctifs moteur de Night City Online déjà identifiés par MrYar07 (use-after-free, RPC, flecs).
4. Critère : le jeu atteint le menu en `-online`, puis se connecte au serveur Docker local.

## État du poste après le test

- Frameworks 2.5 installés et laissés en place. L'option de lancement Steam reste active.
- Mod CyberpunkMP **retiré** du jeu (déplacé dans `~/Backups/test-cpmp/`). Le jeu se lance normalement.
- Logs bruts dans `~/Backups/test-cpmp/logs/`.
