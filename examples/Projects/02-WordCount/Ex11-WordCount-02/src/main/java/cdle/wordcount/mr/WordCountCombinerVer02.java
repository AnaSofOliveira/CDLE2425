package cdle.wordcount.mr;

import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import cdle.wordcount.mr.formaters.input.MyLogUtils;

public class WordCountCombinerVer02
		extends Reducer<Text, IntWritable, Text, IntWritable> {
	
	private static Log log;
	
	static {
		Class<?> klass;
		klass = WordCountCombinerVer02.class;
		
		log = LogFactory.getLog( klass );
		MyLogUtils.showDebugLevel( log, klass );
	}
	
	private IntWritable result = new IntWritable();
	
	@Override
    public void setup(Context context) 
    		throws IOException, InterruptedException {
    	
    	if ( log.isInfoEnabled() ) {
    		String msg = String.format( "%s#setup(%s) called", WordCountCombinerVer02.class.getSimpleName(), context.getJobName() );
    		
    		log.info( msg );

			log.error("---------------test------------------");
    		System.out.printf( "[INFO] %s\n", msg );
			System.out.printf( "[INFO] %s\n", "---------------test------------------" );
		}
    	super.setup( context );
	}
	
	@Override
	public void reduce(Text key, Iterable<IntWritable> values, Context context)
			throws IOException, InterruptedException {
		
		int sum = 0;
		for (IntWritable val : values) {
			sum += val.get();
		}
		
		this.result.set( sum );
		
		context.write(key, this.result );
	}
	
	@Override
	public void cleanup(Context context) 
			throws IOException, InterruptedException {

		if ( log.isDebugEnabled() ) {
			String msg;
			msg = String.format( "%s#cleanup(%s) called", WordCountCombinerVer02.class.getSimpleName(), context.getJobName() );
			
			log.info( msg );
			
    		System.out.printf( "[INFO] %s\n", msg );
		}
		
		super.cleanup( context );
	}
}
