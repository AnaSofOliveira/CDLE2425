package cdle.wordcount.mr;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class WordCountApplication extends Configured implements Tool {

	@Override
	public int run(String[] args) throws Exception {
		if (args.length < 2) {
			System.err.println("hadoop ... <input path> <output path> [number of reducers]");
			System.exit(-1);
		}

		FileSystem fs = FileSystem.get(getConf());

		try{
			fs.copyToLocalFile(new Path(args[0]), new Path(args[1]));
			System.out.println("Dados copiados com sucesso do filesystem do HDFS: " + args[0] + " para o filesystem local: " + args[1]);
			return 1;
		} catch (Exception e) {
			System.out.println("Erro ao copiar do filesystem do HDFS: " + args[0] + " para o filesystem local: " + args[1]);
			return 0;
		}
	}

	
	public static void main(String[] args) throws Exception {
		long startTime = System.nanoTime();
		
		int exitCode = ToolRunner.run(new WordCountApplication(), args);

		long duration_ms = (System.nanoTime() - startTime)/1000000;
		double duration_sec = duration_ms / 1000.0;

		System.out.println("Tempo de execução: ");
		System.out.println(duration_ms + "ms | " + duration_sec + "s");

		System.exit(exitCode);
	}
}
