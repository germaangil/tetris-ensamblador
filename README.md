# Proyecto Tetris en Ensamblador

## Descripción
Este proyecto consiste en la implementación del popular juego Tetris utilizando el lenguaje ensamblador para el entorno de desarrollo MARS (MIPS Assembler and Runtime Simulator).

El archivo ejecutable principal es `tetris.s`, que representa una traducción del código fuente original escrito en C (`tetris.c`) al lenguaje ensamblador.

---

## Objetivo del Proyecto
El principal objetivo de este trabajo ha sido realizar un proceso de traducción manual del código de un programa funcional en C al ensamblador, respetando la lógica original y ajustándola a las particularidades de la arquitectura MIPS.

Este proyecto no solo busca reproducir el juego de Tetris en ensamblador, sino también profundizar en:
- El conocimiento de la arquitectura MIPS.
- La optimización de código ensamblador.
- La comprensión del flujo de control y manejo de memoria.

---

## Requisitos
Para ejecutar este proyecto necesitas:
- MARS: Descargar en http://courses.missouristate.edu/KenVollmar/mars/
- Conocimientos básicos del lenguaje ensamblador MIPS y del uso del entorno MARS.

---

## Estructura del Proyecto
- `tetris.s`: Código fuente del juego en ensamblador MIPS.
- `tetris.c` (opcional): Archivo original en C usado como referencia para la traducción.

---

## Instrucciones de Ejecución
1. Abre el entorno MARS.
2. Carga el archivo `tetris.s` en el editor.
3. Ensambla el programa:
   - Ve a Run > Assemble.
4. Ejecuta el programa:
   - Ve a Run > Go.

---

## Características
- Representación de las piezas clásicas de Tetris (“Tetrominos”).
- Movimiento de las piezas hacia abajo y control del jugador para moverlas y rotarlas.
- Líneas que se eliminan al completarse.
- Sistema de puntuación.

---

## Retos y Soluciones
1. **Manejo de memoria**: La gestión de pilas y registros para almacenar variables temporales fue optimizada para garantizar la eficiencia.
2. **Traducción de estructuras complejas**: Estructuras como bucles y condiciones del código en C requirieron adaptaciones cuidadosas para ensamblador.
3. **Visualización en MARS**: Se implementaron estrategias de salida para simular el tablero en consola.

---

## Contribuciones
Si deseas contribuir a este proyecto, por favor:
1. Haz un fork del repositorio.
2. Realiza tus cambios.
3. Envía un pull request con una descripción de las mejoras.

---

## Contacto

Si tienes alguna pregunta o sugerencia sobre este proyecto, no dudes en contactarme a través de german.gilp@um.es o por teléfono o WhatsApp 693060816.