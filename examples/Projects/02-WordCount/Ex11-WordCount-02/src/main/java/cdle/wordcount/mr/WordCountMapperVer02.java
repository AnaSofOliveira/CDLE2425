package cdle.wordcount.mr;

import java.io.IOException;
import java.net.URI;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.StringTokenizer;

import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;

import cdle.wordcount.mr.formaters.input.MyLogUtils;

public class WordCountMapperVer02
		extends Mapper<Object, Text, Text, IntWritable> {
	
	private static Log log;
	
	static {
		Class<?> klass;
		klass = org.apache.hadoop.mapreduce.Mapper.class;
		
		log = LogFactory.getLog( klass );
		MyLogUtils.showDebugLevel( log, klass );
		
		klass = WordCountMapperVer02.class;
		
		log = LogFactory.getLog( klass );
		MyLogUtils.showDebugLevel( log, klass );
	}
	
	private static final IntWritable one = new IntWritable(1);
	
    private Text word = new Text();
    
    private boolean caseSensitive;
    private Set<String> patternsToSkip = new HashSet<String>();

	private int n;
        
    @Override
    public void setup(Context context) 
    		throws IOException, InterruptedException {
    	
    	if ( log.isInfoEnabled() ) {
    		String msg = String.format( "%s#setup(%s) called", WordCountMapperVer02.class.getSimpleName(), context.getJobName() );
    		
    		log.info( msg );
    		System.out.printf( "[INFO] %s\n", msg );
		}
    	
    	Configuration conf;
    	conf = context.getConfiguration();

		this.n = conf.getInt("wordcount.case.ngram.size", 2);
		if ( log.isDebugEnabled() ) {
    		String msg = String.format( "wordcount.case.ngram.size=%d", this.n );
    		log.debug( this.n );
    		log.debug( msg );
    		System.out.printf( "[DEBUG] %s\n", msg );
		}
    	
    	this.caseSensitive = conf.getBoolean( "wordcount.case.sensitive", false );
    	if ( log.isDebugEnabled() ) {
    		String msg = String.format( "wordcount.case.sensitive=%b", this.caseSensitive );
    		
    		log.debug( msg );
    		System.out.printf( "[DEBUG] %s\n", msg );
			
		}

    	boolean skipPatterns;
    	skipPatterns = conf.getBoolean( "wordcount.skip.patterns", true);
    	if ( log.isDebugEnabled() ) {
    		String msg = String.format( "wordcount.skip.patterns=%b", skipPatterns );
    		
    		log.debug( msg );
    		System.out.printf( "[DEBUG] %s\n", msg );
		}
    	
    	if ( skipPatterns==true ) {
    		URI[] patternsURIs = Job.getInstance( conf ).getCacheFiles();
    		
    		for (URI patternsURI : patternsURIs) {
    			if ( log.isDebugEnabled() ) {
    				String msg = String.format( "Current pattern file: %s", patternsURI.getPath() );
    	    		
    				log.debug( msg );
    	    		System.out.printf( "[DEBUG] %s\n", msg );
    			}
    			
    			Path patternsPath;
    			patternsPath = new Path( patternsURI.getPath() );
    			String patternsFileName;
    			patternsFileName = patternsPath.getName().toString();
    			
    			if ( patternsFileName.endsWith( ".txt" ) ) {
    				if ( log.isDebugEnabled() ) {
    					String msg = String.format( "Parsing %s", patternsFileName );
    				
    					log.debug( msg );
        	    		System.out.printf( "[DEBUG] %s\n", msg );
    				}
    				WordCountUtils.parseSkipFile( this.patternsToSkip, patternsFileName);
    			}	
        }
      }
    }
	
	@Override
	public void map(Object key, Text value, Context context) 
			throws IOException, InterruptedException {

		String line;
		line = ( this.caseSensitive) ? value.toString() : value.toString().toLowerCase();
		
		for (String pattern : this.patternsToSkip ) {
			line = line.replaceAll(pattern, "" );
		}
		StringTokenizer itr = new StringTokenizer( line );
		/*
		List<String> tokens = new ArrayList<>();

		String[] values = line.split(" ");

		if(values.length > n) {
			String[] result = ArrayUtils.subarray(values, 0, n);

			int nGramasLinha = result.length +1;
		}if (values.length == n) {
			context.write( this.word, WordCountMapperVer02.one);
			context.getCounter( WordCountUtils.Statistics.TotalWords ).increment( 1 );
		}*/


		List<String> words = new ArrayList<>();

		while ( itr.hasMoreTokens() ) {
			String w = itr.nextToken();
			

			if(words.size() == n) {
				words.remove(0);
			}

			words.add(w);

			if(words.size() == n) {
				String combinedText = String.join(" ", words);
				this.word.set( combinedText );
				context.write( this.word, WordCountMapperVer02.one);
				context.getCounter( WordCountUtils.Statistics.TotalWords ).increment( 1 );
			}
			
	
			//context.write( this.word, WordCountMapperVer02.one);
			
			//context.getCounter( WordCountUtils.Statistics.TotalWords ).increment( 1 );
		}
	}
	
	@Override
	public void cleanup(Context context) 
			throws IOException, InterruptedException {

		if ( log.isInfoEnabled() ) {
			String msg = String.format( "%s#cleanup(%s) called", WordCountMapperVer02.class.getSimpleName(), context.getJobName() );

			log.info( msg );
    		System.out.printf( "[INFO] %s\n", msg );
		}
		
		super.cleanup( context );
	}
}
