

def parse_header(lines):
    """
    Extrai a data de aquisição e a taxa de amostragem do header do arquivo.

    Args:
        lines (array): As primeiras linhas do arquivo de dados (header).

    Returns:
        dict: Informações extraídas do header.
    """
    extraction_date = lines[0].strip().split(":=")[-1]  # Extrai data de aquisição
    sampling_rate = lines[1].strip().split(":=")[-1]  # Extrai taxa de amostragem

    return {
        "extraction_date": extraction_date,
        "sampling_rate": sampling_rate, 
        "testes": lines
    }

def load_ecg_data(lines):
    """
    Carrega o sinal de ECG a partir das linhas do arquivo, ignorando o header.

    Args:
        lines (list): Linhas do arquivo de dados.

    Returns:
        list: Sinal de ECG como uma lista de valores inteiros.
    """
    ecg_data = [int(line.split()[1]) for line in lines[3:] if line.strip()]  # Segunda coluna assume ECG
    return ecg_data

def segment_signal(ecg_data, samples_per_segment):
    """
    Divide o sinal de ECG em segmentos de duração definida.

    Args:
        ecg_data (list): Sinal de ECG como uma lista de inteiros.
        samples_per_segment (int): Número de amostras por segmento (ex: 1000 para 1 segundo a 1000 Hz).

    Yields:
        list: Segmento de ECG com o número especificado de amostras.
    """
    for i in range(0, len(ecg_data), samples_per_segment):
        segment = ecg_data[i:i + samples_per_segment]
        if len(segment) == samples_per_segment:
            yield segment
