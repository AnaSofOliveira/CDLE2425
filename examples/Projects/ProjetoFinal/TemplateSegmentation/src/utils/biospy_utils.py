from biosppy.signals import ecg

def identify_templates(ecg_signal, sampling_rate):
    """
    Identifica templates em um segmento de sinal ECG usando BioSpy.

    Args:
        ecg_signal (list): Segmento de sinal de ECG.
        sampling_rate (int): Taxa de amostragem do sinal.

    Returns:
        list: Lista de templates identificados no segmento.
    """
    # Usa BioSpy para analisar o segmento e extrair templates
    return ecg.ecg(signal=ecg_signal, sampling_rate=sampling_rate, show=False)
