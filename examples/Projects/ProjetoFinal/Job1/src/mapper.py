#!/usr/bin/python3
import os
import sys
from examples.Projects.ProjetoFinal.TemplateSegmentation.src.utils.biospy_utils import identify_templates
from src.utilities.data_processing import parse_header, load_ecg_data, segment_signal

def mapper():
    # Obtém o nome do arquivo de entrada
    filename = os.environ['map_input_file']
    user_id = filename.split("_u")[-1].split(".")[0]  # Extrai o ID do usuário do nome do arquivo
    
    # Lê o conteúdo do arquivo
    with open(filename, 'r') as file:
        lines = file.readlines()
    
    # Extrai informações do header e carrega o sinal de ECG
    header_info = parse_header(lines)  # Ex.: {'sampling_rate': 1000}
    ecg_data = load_ecg_data(lines)    # Lista com as amostras do sinal ECG
    samples_per_second = header_info["sampling_rate"]

    # Segmenta o sinal em blocos de um segundo e identifica templates usando BioSpy
    for segment in segment_signal(ecg_data, samples_per_second):
        templates = identify_templates(segment, samples_per_second)
        # Emite o user_id como chave e os templates como valor
        print(f"{user_id}\t{templates}")

if __name__ == "__main__":
    mapper()
