from mrjob.job import MRJob

class TemplateSegmentation(MRJob):

    def mapper(self, _, line): 

        # # Obtém o nome do arquivo de entrada
        # filename = os.environ['map_input_file']
        # user_id = filename.split("_u")[-1].split(".")[0]  # Extrai o ID do usuário do nome do arquivo
        
        # # Lê o conteúdo do arquivo
        # with open(filename, 'r') as file:
        #     lines = file.readlines()
        
        # # Extrai informações do header e carrega o sinal de ECG
        # header_info = parse_header(lines)  # Ex.: {'sampling_rate': 1000}
        # ecg_data = load_ecg_data(lines)    # Lista com as amostras do sinal ECG
        # samples_per_second = header_info["sampling_rate"]

        # # Segmenta o sinal em blocos de um segundo e identifica templates usando BioSpy
        # for segment in segment_signal(ecg_data, samples_per_second):
        #     templates = identify_templates(segment, samples_per_second)
        #     # Emite o user_id como chave e os templates como valor
        #     print(f"{user_id}\t{templates}")
            
        raise NotImplementedError
    


    def reducer(self, key, values): 

        # current_user = None
        # all_templates = []

        # for line in sys.stdin:
        #     # Descompacta a chave (user_id) e o valor (templates) da linha
        #     user_id, templates = line.strip().split("\t", 1)
        #     templates = json.loads(templates)  # Converte a string JSON para uma lista

        #     # Se o user_id mudou, imprime o resultado acumulado para o usuário anterior
        #     if current_user != user_id:
        #         if current_user is not None:
        #             print(f"{current_user}\t{all_templates}")
        #         current_user = user_id
        #         all_templates = []

        #     # Adiciona os templates do segmento atual à lista acumulada
        #     all_templates.extend(templates)

        # # Imprime os templates para o último usuário
        # if current_user is not None:
        #     print(f"{current_user}\t{all_templates}")

            
        raise NotImplementedError
    

if __name__ == '__main__':
    TemplateSegmentation.run()