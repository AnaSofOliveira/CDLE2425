import matplotlib.pyplot as plt
import numpy as np
import sys
import json
import io
import base64
import gzip
import os


'''
def reducer(self, key, values):
    user, ts = key
    temps = np.array(list(values)[0])
    self.logger.debug(f'[reducer] key: {key} values {temps}')
    plt.figure(f'{user}_{ts}')
    plt.plot(temps.T)
    plt.title('Templates person {}'.format(user))

    #self.logger.info(f'reducer output_dir: {self.options.output_img}')
    #self.logger.info(f'reducer options: {self.options}')
    buffer = io.BytesIO()
    plt.savefig(buffer, format="png")
    buffer.seek(0) 
    #output_dir = self.options.output_img
    #os.makedirs(output_dir, exist_ok=True)
    #output_file = os.path.join(output_dir, f'{user}.png')
    #plt.savefig(output_file)
    encoded_image = base64.b64encode(buffer.read()).decode('utf-8')
    buffer.close()
    plt.close()

    yield key, encoded_image
'''

def read(line):
    key, value = line.split('\t', 1)
    key = json.loads(key)
    value = json.loads(value)
    return key, value


if __name__ == "__main__":
    path_file = sys.argv[1]
    path_images = sys.argv[2]
    n = 5

    print(f'path_file: {path_file}')
    with gzip.open(path_file, 'rt') as f:
        for i, line in enumerate(f):
            if i >= n:
                break 
            print(line[:100])
            key, value = read(line)
            temps = np.array(value)
            user = key[0]
            ts = key[1]
            filename = f'{user}_{ts}_{i}'
            if len(key) > 3:
                filename = f'{filename}_{key[3]}'
        
            plt.figure(f'{user}_{i}')
            plt.plot(temps.T)
            plt.title('Templates person {}'.format(user))


            #output_dir = self.options.output_img
            os.makedirs(f'{path_images}/imgs', exist_ok=True)
            output_file = os.path.join(f'{path_images}/imgs', f'{filename}.png')
            plt.savefig(output_file)
            plt.close()
            