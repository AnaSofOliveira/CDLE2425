import json
from biosppy.signals import ecg
from biosppy.clustering import outliers_dmean, outliers_dbscan
import numpy as np

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

def outlier_detection_dmean(templates, alpha = 0.5, beta = 1.5):
    temp = np.array(templates)
    out = outliers_dmean(data=temp, alpha=alpha, beta=beta) # detectar outliers D-Mean 
    idx = out['clusters'][0] # indices dos templates que não são outliers
    idx_out = out['clusters'][-1] # indices dos templates que são outliers
    return temp[idx].tolist(), temp[idx_out].tolist() # retorna os templates que não são outliers e os que são outliers

def outlier_detection_dbscan(templates, e = 0.005, min_samples = 15, metric = 'correlation'):
    temp = np.array(templates)
    out = outliers_dbscan(data=temp, eps=e, min_samples=min_samples, metric=metric) # detectar outliers dbscan 
    idx = out['clusters'][0] # indices dos templates que não são outliers
    idx_out = out['clusters'][-1] # indices dos templates que são outliers
    return temp[idx].tolist(), temp[idx_out].tolist() # retorna os templates que não são outliers e os que são outliers

def load_json(file):
    with open(file, 'r') as f:
        return json.load(f)


def filter_value(v1, v2):
    if len(v1) == 0:
        return True
    for v in v1:
        if v == v2:
            return True
    return False

def filter_date(start, end, date):
    from datetime import datetime
    if start is None or end is None:
        return True
    
    start_date = datetime.strptime(start, "%Y-%m-%dT%H:%M:%SZ")
    end_date = datetime.strptime(end, "%Y-%m-%dT%H:%M:%SZ")
    date_to_check = datetime.strptime(date, "%Y-%m-%dT%H:%M:%S.%f")

    if start_date <= date_to_check <= end_date:
        return True
    else:
        return False
    