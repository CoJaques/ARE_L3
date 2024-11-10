# Laboratoire 03 – Conception d’une interface simple

**Cours :** Architecture des systèmes embarqués (ARE)  
**Étudiants :** Colin Jaques, Theodros Mulugeta  
**Date :** 10 novembre 2024  

---

HEIG-VD

# Introduction

Ce rapport présente le travail réalisé dans le cadre du troisième laboratoire du cours "Architecture des systèmes embarqués (ARE)", intitulé "Conception d’une interface simple". L'objectif principal de ce laboratoire est de concevoir et implémenter une interface matérielle connectée au bus Avalon pour contrôler divers périphériques de la carte DE1-SoC, ainsi qu'une liaison parallèle vers une carte Max10_leds. Le rapport détaille les différentes étapes de la conception, de la simulation et des tests, tout en mettant en évidence les choix techniques effectués pour répondre aux spécifications demandées.

<br>

---

# Plan d'adressage

Afin de concevoir notre interface, nous avons dû élaborer un plan d'adressage permettant de définir les méthodes d'accès entre le CPU et le FPGA.

La taille de la zone disponible pour l'interface correspond à 14 bits d'adresse, car la plage définie s'étend de 0x01_0000 à 0x01_FFFF, ce qui représente un espace total de 64 Ko.

Cependant, seuls 14 bits sont nécessaires pour adresser un registre du côté FPGA. En effet, l'adressage se fait par blocs de 4 octets (32 bits) et non par octets individuels. Par conséquent, les deux bits de poids faible des adresses ne sont pas utilisés dans l'adressage côté FPGA. Cela réduit le nombre effectif de bits nécessaires, rendant 14 bits suffisants pour couvrir l'ensemble de la plage de 64 Ko.

Lors de la conception de notre plan d'adressage, nous avons cherché à rendre celui-ci adaptable et modulable. La plage d'adresses disponible étant largement suffisante pour nos besoins, nous l'avons divisée en plusieurs sections.

Première partie (0x4000 à 0x401F) : dédiée à des registres en lecture seule. Seules certaines adresses de cette plage sont utilisées, tandis que les autres sont réservées pour de potentielles extensions futures.
Deuxième partie (0x4020 à 0x403F) : dédiée à des registres en lecture/écriture.
Dernière partie (0x4040 à 0x7FFF) : laissée libre et non réservée, car elle n'est pas utilisée dans notre conception actuelle.
Pour les registres où seuls certains bits parmi les 32 bits sont utilisés, nous avons décidé de mettre les bits inutilisés à 0. Cette approche permet d'éviter les problèmes de lecture ou d'écriture dans des zones non définies et simplifie la gestion des données, en supprimant la nécessité d'appliquer des masques lors des opérations de lecture.

## Plan d'adressage final

| **CPU**                        | **FPGA**           | **Commment**          | **Read**                         | **Write**                 |
|--------------------------------|--------------------|-----------------------|----------------------------------|---------------------------|
| `0xFF21 0000`                  | `0x4000`           | ID constant           | `Constant[31:0]`                 | Reserved                  |
| `0xFF21 0004`                  | `0x4001`           | Buttons               | `res[31:4]  => 0 buttons[3:0]`   | Reserved                  |
| `0xFF21 000C`                  | `0x4003`           | Switches              | `res[31:10] => 0 switches[9:0]`  | Reserved                  |
| `0xFF21 0010`                  | `0x4004`           | LP36 status           | `res[31:2]  => 0 lp36-stat[1:0]` | Reserved                  |
| `0xFF21 0014`                  | `0x4005`           | LP36 ready            | `res[31:1]  => 0 lp36-rdy[0]`    | Reserved                  |
| `0xFF21 0018 -> 0x00FF21 007C` | `0x4006 -> 0x401F` |                       | Reserved                         | Reserved                  |
| `0xFF21 0080`                  | `0x4020`           | Leds                  | `res[31:10] => 0 leds[9:0]`      | `res[31:10] leds[9:0]`    |
| `0xFF21 0084`                  | `0x4021`           | LP36 sel              | `res[31:4]  => 0 lp36_sel[3:0]`  | `res[31:4] lp36_sel[3:0]` |
| `0xFF21 0088`                  | `0x4022`           | LP36 data             | `lp36_data[31:0]`                | `lp36_data[31:0]`         |
| `0xFF21 008C -> 0x00FF21 00FC` | `0x4023 -> 0x403F` |                       | Reserved                         | Reserved                  |
| `0xFF21 0100 -> 0x00FF21 FFFF` | `0x4040 -> 0x7FF`  |                       | Free                             | Free                      |

<br>

# Conception

## Schéma de principe

## Avalon

### Lecture

### Écriture

## LP36 spécifique

# Implémetation

# Code C

# Conclusion