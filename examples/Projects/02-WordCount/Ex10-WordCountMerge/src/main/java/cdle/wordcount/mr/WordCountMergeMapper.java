package cdle.wordcount.mr;

import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class WordCountMergeMapper
			extends Mapper<Object, Text, Text, IntWritable> {
	
    private Text word = new Text();
	private IntWritable count = new IntWritable();
	
	@Override
	public void map(Object key, Text value, Context context) throws IOException, InterruptedException {

		// Read line
		String line = value.toString();

		// The line is in the format: word count
		// Regex to split the line by any whitespace (space, tab, etc.)
		String[] parts = line.split("\\s+");
		if (parts.length == 2) {
			// Get word
			
			word.set(parts[0]);
			// Get Count
			count.set(Integer.parseInt(parts[1]));

			// Emit word and count
			context.write(word, count);
		}
	}
}









