from datetime import datetime
import json
import os
import sys
import logging
from mrjob.job import MRJob
from mrjob.protocol import RawValueProtocol
from utils.biospy_utils import identify_templates
from utils.data_processing import parse_header, load_ecg_data, segment_signal

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s',
    handlers=[
        logging.StreamHandler()  # You can add more handlers, like FileHandler, if needed
    ]
)

class TemplateSegmentation(MRJob):

    current_user = None
    aquisition_date = None
    fs = None

    # Ensure input files are not split
    INPUT_PROTOCOL = RawValueProtocol
    INPUT_SPLITTING = False

    def mapper(self, _, line):

        global current_user, aquisition_date, fs

        file_path = os.environ['map_input_file']
        file_name = os.path.basename(file_path)
        current_user = file_name.split(".")[0].split("_")[-1]

        if ("Date" in line):
            date_string = line.strip().split(":=")[-1].strip()
            aquisition_date = date_string # datetime.strptime(date_string, '%Y-%m-%dT%H:%M:%S.%f')
        elif ("Sampling" in line):
            fs = line.strip().split(":=")[-1]
        elif ("Labels" in line):
            pass
        else:
            lod, ecg_sample, ts = line.split("\t")
            if lod == "1":
                # logging.info(f"[Mapper] Will yield: ({current_user}, {aquisition_date}), ({ecg_sample}, {fs}) \n")
                yield (current_user, aquisition_date), (ecg_sample, fs)


    def combiner(self, key, values):
        values_list = list(values)
        sinal = [int(value[0]) for value in values_list]
        fs = [int(value[1]) for value in values_list][0]
        # logging.info(f"Combining values for key: {key}")
        try: 
            result = identify_templates(sinal, fs)
            templates = result['templates']
            # logging.info(f"[Combiner] Will yield: {key}, ({templates.tolist()}, {fs}) \n")
            yield key, (templates.tolist(), fs)
        except Exception as e:
            logging.error(f"Error ao indentificar templates para o utilizador: {key[0]}")
            yield key, ([], fs)
            

    def reducer(self, key, values):

        all_templates = []

        logging.info(f"[Reducer] Key: {key}")

        for value in values: 
            logging.info(f"[Reducer] Value: {len(value)}, {value[0][0][:5]}")
            # logging.info(f"[Reducer] Value: {len(value)}, {len(value[0])}, {len(value[0][0])}") # (2, 15, 600)   
            all_templates.append(value[0][0][:5])

        yield key, all_templates



if __name__ == '__main__':
    start_time = datetime.now()
    TemplateSegmentation.run()
    end_time = datetime.now()
    logging.info(f"Process completed in: {end_time - start_time}")