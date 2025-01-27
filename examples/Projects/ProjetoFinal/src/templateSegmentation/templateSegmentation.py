import os
from mrjob.job import MRJob
from mrjob.step import MRStep
from mrjob.protocol import RawValueProtocol
from protocol import HadoopSequenceFileProtocol
from utils import config_logs

class TemplateSegmentation(MRJob):

    INPUT_PROTOCOL = RawValueProtocol
    #INPUT_SPLITTING = False
    OUTPUT_PROTOCOL = HadoopSequenceFileProtocol

    def configure_args(self):
        super(TemplateSegmentation, self).configure_args()
        self.add_passthru_arg(
            '--log-level', type=str, default='INFO',
            help="Set log level (e.g., DEBUG, INFO, WARNING, ERROR)"
        )

    def load_args(self, args):
        super(TemplateSegmentation, self).load_args(args)
        self.logger = config_logs(self.options.log_level)
        self.logger.info(f'[Log level] set to: {self.options.log_level}')

    def mapper_init(self):
        file_path = os.environ.get('map_input_file')
        file_name = os.path.basename(file_path)
        self.current_user = file_name.split(".")[0].split("_")[-1]
        self.logger.debug(f"current_user: {self.current_user} \n")

    def mapper(self, _, line):
        self.logger.debug(f"line: {line} \n")
        if ("Date" in line):
            date_string = line.strip().split(":=")[-1].strip()
            self.aquisition_date = date_string # datetime.strptime(date_string, '%Y-%m-%dT%H:%M:%S.%f')
            self.logger.debug(f"aquisition_date: {self.aquisition_date} \n")
        elif ("Sampling" in line):
            self.fs = int(line.strip().split(":=")[-1].strip())
            self.logger.debug(f"frequen: {self.fs} \n")
        elif ("Labels" in line):
            pass
        else:
            lod, ecg_sample, ts = line.split("\t")
            if lod == "1":
                self.logger.debug(f"[Mapper] Will yield: ({self.current_user}, {self.aquisition_date}), ({ecg_sample}, {self.fs}) \n")
                yield (self.current_user, self.aquisition_date, self.fs), ecg_sample

    def combiner(self, key, values):
        from biospy_utils import identify_templates
        values_list = list(values)
        sinal = [int(value) for value in values_list]
        user, ts, fs = key 
        try: 
            result = identify_templates(sinal, fs)
            templates = result['templates']
            self.logger.debug(f"[Combiner] Will yield: {key}, ({templates.tolist()}, {fs}) \n")
            yield (user, ts, fs), templates.tolist()
        except Exception as e:
            self.logger.error(f"Error ao indentificar templates para o utilizador: {key[0]}")
            yield key, []

    def reducer(self, key, values):
        user, ts, fs = key
        temps = list(values)[0]
        for i in range(len(temps)):
            yield (user, ts, fs, i), temps[i]


    def steps(self):
        return [
            MRStep(
                mapper_init=self.mapper_init,
                mapper=self.mapper,
                combiner=self.combiner,
                reducer=self.reducer
            ) 
        ]

if __name__ == '__main__':
    TemplateSegmentation.run()
    