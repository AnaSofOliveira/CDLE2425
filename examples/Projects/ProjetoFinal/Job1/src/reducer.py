#!/usr/bin/python3
import sys
import json

def reducer():
    current_user = None
    all_templates = []

    for line in sys.stdin:
        # Descompacta a chave (user_id) e o valor (templates) da linha
        user_id, templates = line.strip().split("\t", 1)
        templates = json.loads(templates)  # Converte a string JSON para uma lista

        # Se o user_id mudou, imprime o resultado acumulado para o usuário anterior
        if current_user != user_id:
            if current_user is not None:
                print(f"{current_user}\t{all_templates}")
            current_user = user_id
            all_templates = []

        # Adiciona os templates do segmento atual à lista acumulada
        all_templates.extend(templates)

    # Imprime os templates para o último usuário
    if current_user is not None:
        print(f"{current_user}\t{all_templates}")

if __name__ == "__main__":
    reducer()
