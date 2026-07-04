#!/bin/bash
# Carrega o módulo caso não esteja no boot
modprobe ryzen_smu
# Espera 1 segundo para garantir que o device está pronto
sleep 1
# Aplica o undervolt (ajuste o caminho para onde o ruv.py está)
python3 /home/nykot/Ryzen-5800x3d-linux-undervolting/ruv.py -c 16 -o -30
