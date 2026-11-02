# Feuille de route du moteur

| Étape | Contenu | Critère de fin | Statut |
| --- | --- | --- | --- |
| M0 | Build reproductible du moteur d'origine | Build Windows et image Docker en CI | À faire |
| M1 | Portage sur le patch 2.5 | Deux joueurs se connectent, se voient et se déplacent | À faire |
| M2 | Limitation de débit réseau | Un client qui inonde le serveur n'en dégrade pas les performances | À faire |
| M3 | Extension du SDK serveur | L'adaptateur RP n'a besoin d'aucune modification du moteur | À faire |
| M4 | Releases automatisées | Chaque tag publie client, serveur, SDK et empreintes | À faire |
| M5 | Évaluation combat, PNJ, objets du monde | Rapport : ce qui est synchronisé, ce qui manque, coût estimé | À faire |

M1 conditionne la suite de tout le projet. Le détail des exigences est dans le [cahier des charges](fonctionnel/cahier-des-charges.md).

## Sources d'étude

D'autres forks ont déjà porté le moteur sur des patchs récents, notamment [Night City Online](https://github.com/ofmiceandcam98-eng/CyberpunkMP) (patch 2.31) et [MrYar07/CyberpunkMP](https://github.com/MrYar07/CyberpunkMP) (patch 2.5). Ils sont sous la même licence : leur code peut être repris ici, avec attribution à leurs auteurs.
