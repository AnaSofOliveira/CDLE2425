package cdle.wordcount.mr;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.hadoop.io.compress.GzipCodec;


public class WordCountApplication extends Configured implements Tool{
	
	@Override
	public int run(String[] args) throws Exception {
		if ( args.length<2 ) {
			System.err.println( "hadoop ... <input path> <output path> [number of reducers]" );
			System.exit(-1);
		}
		
		Job job = Job.getInstance( getConf() );
		
		job.setJarByClass( WordCountApplication.class );
		job.setJobName( "Word Count Ver 1" );
		
		// Add several inputs
		for (int i = 0; i < args.length - 1; i++) {
			FileInputFormat.addInputPath(job, new Path(args[i]));
		}
		FileOutputFormat.setOutputPath( job, new Path(args[1]) );
		
		job.setMapperClass( WordCountMergeMapper.class );
		job.setCombinerClass( WordCountMergeReducer.class );
		job.setReducerClass( WordCountMergeReducer.class );
		
		// Output types of map function
		job.setMapOutputKeyClass( Text.class );
		job.setMapOutputValueClass( IntWritable.class );
		
		try {
			int numberOfReducers;
			numberOfReducers = Integer.parseInt( args[2] );
			job.setNumReduceTasks( numberOfReducers );
			System.out.printf( "Setting number of reducers to %d\n", numberOfReducers );
		}
		catch (Exception e) {
			System.out.println( "Using default number (1) of reducers" );
		}

		// // Enable compression
		// FileOutputFormat.setCompressOutput(job, true);
		// FileOutputFormat.setOutputCompressorClass(job, GzipCodec.class);
		// System.out.printf( "Setting compreession to GZip");
		
		// Output types of reduce function
		job.setOutputKeyClass( Text.class );
		job.setOutputValueClass( IntWritable.class );
		
		return job.waitForCompletion(true) ? 0 : 1;
	}

	public static void main(String[] args) throws Exception {
		int exitCode = ToolRunner.run(new WordCountApplication(), args);
		System.exit(exitCode);
	}
}
