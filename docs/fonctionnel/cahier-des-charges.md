# Cahier des charges du moteur

| | |
| --- | --- |
| Version | 0.1 — 2026-11-02 |
| Statut | Brouillon |
| Projet parent | POC-CyberpunkRP |

## 1. Contexte et besoin

Le serveur RP POC-CyberpunkRP repose sur CyberpunkMP. Le moteur d'origine n'est plus maintenu depuis décembre 2024 et ne démarre plus sur les patchs actuels du jeu.

Le besoin : un moteur qui tourne sur la version actuelle du jeu, robuste face aux abus réseau, et qui expose assez de points d'extension pour que **toute** la logique RP vive dans des plugins, sans modifier le moteur.

## 2. Périmètre

**Dans ce dépôt** : portage, robustesse réseau, extension du SDK, nouvelles synchronisations entre joueurs, outillage de build et de release.

**Hors de ce dépôt** : toute règle métier (économie, métiers, justice), la voix, le launcher. Ils appartiennent au projet parent.

## 3. Exigences

### Fonctionnelles

| Code | Exigence | Cible |
| --- | --- | --- |
| M-F1 | Le client et le serveur fonctionnent sur le patch 2.5 de Cyberpunk 2077 | POC |
| M-F2 | Le SDK serveur expose les événements de connexion, déconnexion et position des joueurs | POC |
| M-F3 | Le SDK serveur permet de faire apparaître et retirer un véhicule, téléporter un joueur, donner ou retirer un objet | POC |
| M-F4 | Le SDK serveur permet d'identifier un joueur de manière fiable (identifiant de compte vérifié) | POC |
| M-F5 | Le serveur peut refuser une connexion selon une décision d'un plugin (ban) | POC |
| M-F6 | Synchronisation de la santé, des dégâts et de la mort entre joueurs | MVP, après évaluation |
| M-F7 | Synchronisation des PNJ et objets du monde nécessaires au RP (portes, ascenseurs) | MVP, après évaluation |

### Non fonctionnelles

| Code | Exigence | Mesure |
| --- | --- | --- |
| M-NF1 | Débit entrant limité par client et par type de message | Un client qui envoie 1 000 paquets/s ne dégrade pas le serveur |
| M-NF2 | Aucune valeur reçue du client n'est acceptée sans validation (positions finies, bornes du monde) | Test avec paquets malformés |
| M-NF3 | Build reproductible en CI, Windows pour le client, Linux pour le serveur | Build vert sur une machine vierge |
| M-NF4 | Chaque release publie ses binaires, le SDK et leurs empreintes SHA-256 | Vérification par le launcher du projet parent |
| M-NF5 | 20 joueurs simultanés sans dégradation perceptible | Test de charge |

## 4. User stories

### US-M01 — Jouer sur la version actuelle du jeu

*En tant que* joueur, *je veux* utiliser le moteur avec mon jeu à jour, *afin de* ne pas devoir revenir à une ancienne version.

- **Étant donné** Cyberpunk 2077 en version 2.5 avec les frameworks compatibles, **quand** je lance le jeu avec le moteur, **alors** il démarre sans erreur et se connecte au serveur.
- **Étant donné** deux joueurs connectés, **quand** l'un se déplace ou conduit, **alors** l'autre le voit bouger.

Exigences : M-F1.

### US-M02 — Résister à un client malveillant

*En tant qu'*exploitant, *je veux* qu'un client qui inonde le serveur soit freiné, *afin que* les autres joueurs ne soient pas affectés.

- **Étant donné** un client qui envoie des paquets de déplacement au-delà du débit autorisé, **quand** le serveur les reçoit, **alors** l'excédent est ignoré et journalisé une fois par fenêtre de temps.
- **Étant donné** un paquet contenant une position invalide, **quand** le serveur le reçoit, **alors** il est rejeté sans effet sur l'état du monde.

Exigences : M-NF1, M-NF2.

### US-M03 — Brancher la logique RP sans toucher au moteur

*En tant que* développeur du projet parent, *je veux* trouver dans le SDK tout ce dont l'adaptateur a besoin, *afin de* garder la logique RP dans un plugin privé.

- **Étant donné** le SDK publié, **quand** l'adaptateur s'abonne aux connexions et aux positions, **alors** il reçoit les événements correspondants.
- **Étant donné** une décision du backend, **quand** l'adaptateur demande de téléporter un joueur ou de lui donner un objet, **alors** le moteur l'applique et le synchronise.

Exigences : M-F2, M-F3, M-F4, M-F5.

### US-M04 — Récupérer une release vérifiable

*En tant que* launcher du projet parent, *je veux* télécharger une release dont chaque fichier a une empreinte publiée, *afin de* vérifier l'installation des joueurs.

- **Étant donné** un tag de version, **quand** la CI se termine, **alors** la release contient client, serveur, SDK et un fichier d'empreintes.

Exigences : M-NF3, M-NF4.

### US-M05 — Savoir ce que coûte le combat

*En tant que* porteur du projet, *je veux* un rapport sur ce que le moteur synchronise ou non en combat, *afin de* décider de le développer ou non pour le MVP.

- **Étant donné** deux joueurs qui s'affrontent, **quand** l'évaluation est menée, **alors** le rapport liste ce qui est synchronisé, ce qui manque et une estimation de l'effort.

Exigences : M-F6, M-F7.

## 5. Critères de recette du POC

M-F1 à M-F5 satisfaites, M-NF1 à M-NF4 démontrées, US-M01 à US-M04 validées.
