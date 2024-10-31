package cdle.wordcount.mr;

import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class WordCountApplication extends Configured implements Tool{
	
	@Override
	public int run(String[] args) throws Exception {
		if ( args.length<1 ) {
			System.err.println( "hadoop ... <input path> <output path>" );
			System.exit(-1);
		}
		
		Job job = Job.getInstance( getConf() );
		
		job.setJarByClass( WordCountApplication.class );
		job.setJobName( "Word Count Ver 1" );
		
		System.out.println("[WordCountApplication]");
		System.out.println("Input path: " + args[0]);
		System.out.println("Output path: " + args[1]);

		FileInputFormat.addInputPath( job, new Path(args[0]) );
		FileOutputFormat.setOutputPath( job, new Path(args[1]) );
		
		job.setMapperClass( WordCountMapper.class );
		job.setCombinerClass( WordCountReducer.class );
		job.setReducerClass( WordCountReducer.class );
		
		// Output types of map function
		job.setMapOutputKeyClass( Text.class );
		job.setMapOutputValueClass( IntWritable.class );
		
		// try {
		// 	int numberOfReducers;
		// 	numberOfReducers = Integer.parseInt( args[2] );
		// 	job.setNumReduceTasks( numberOfReducers );
		// 	System.out.printf( "Setting number of reducers to %d\n", numberOfReducers );
		// }
		// catch (Exception e) {
		// 	System.out.println( "Using default number (1) of reducers" );
		// }
		
		// Output types of reduce function
		job.setOutputKeyClass( Text.class );
		job.setOutputValueClass( IntWritable.class );
		
		return job.waitForCompletion(true) ? 0 : 1;
	}

	public static void main(String[] args) throws Exception {
        // Use ToolRunner to run the job with the given configuration
        int exitCode = ToolRunner.run(new WordCountApplication(), args);
        System.exit(exitCode);
    }
}
