package cdle.wordcount.mr;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordCountApplication {
	
	public static void main(String[] args) throws Exception {
		if ( args.length<2 ) {
			System.err.println( "hadoop ... <input path> <output path> [number of reducers] [codec]" );
			System.exit(-1);
		}

		
		Configuration conf = new Configuration();
		if(args[3].equals("Gzip")){
			conf.set("mapreduce.output.fileoutputformat.compress", "true");
			conf.set("mapreduce.output.fileoutputformat.compress.codec", "org.apache.hadoop.io.compress.GzipCodec");
		}else if(args[3].equals("Bzip2")){
			conf.set("mapreduce.output.fileoutputformat.compress", "true");
			conf.set("mapreduce.output.fileoutputformat.compress.codec", "org.apache.hadoop.io.compress.BZip2Codec");
		}else{
			conf.set("mapreduce.output.fileoutputformat.compress", "false");
		}
		
		Job job = Job.getInstance( conf );
		
		job.setJarByClass( WordCountApplication.class );
		job.setJobName( "Word Count Ver 1" );
		
		FileInputFormat.addInputPath( job, new Path(args[0]) );
		FileOutputFormat.setOutputPath( job, new Path(args[1]) );
		
		job.setMapperClass( WordCountMapper.class );
		job.setCombinerClass( WordCountReducer.class );
		job.setReducerClass( WordCountReducer.class );
		
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
		
		// Output types of reduce function
		job.setOutputKeyClass( Text.class );
		job.setOutputValueClass( IntWritable.class );
		
		System.exit( job.waitForCompletion(true) ? 0 : 1 );
	}
}
