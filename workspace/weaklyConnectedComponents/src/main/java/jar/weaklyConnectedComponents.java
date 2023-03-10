package jar;

import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.io.BufferedWriter;
import org.apache.flink.graph.Edge;
import org.apache.flink.graph.Graph;
import org.apache.flink.graph.Vertex;
import org.apache.flink.types.NullValue;
import org.apache.flink.api.java.DataSet;
import org.apache.flink.api.java.ExecutionEnvironment;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.graph.library.ConnectedComponents;

public class weaklyConnectedComponents {

	public static void main(String[] args) throws Exception {		
		final ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();

		String edgeListFilePath = "/home/user/data/flink.txt";
		int iters = 10; // Maximum number of iterations

		Graph<Integer, NullValue, NullValue> graph = Graph.fromCsvReader(edgeListFilePath, env).keyType(Integer.class);
		
		// Annotate each vertex with its ID as a value
		Graph<Integer, Integer, NullValue> annotatedGraph = graph.mapVertices(new MapFunction<Vertex<Integer, NullValue>, Integer>() {
			public Integer map(Vertex<Integer, NullValue> value) {
				return value.getId();
			}
		});

		long toc = System.currentTimeMillis();

		ConnectedComponents<Integer, Integer, NullValue> connectedComponents = new ConnectedComponents<>(iters);
		DataSet<Vertex<Integer, Integer>> result = connectedComponents.run(annotatedGraph);

		ArrayList<Vertex<Integer, Integer>> components = new ArrayList<Vertex<Integer, Integer>>();
		result.collect().forEach(components::add);

		long tic = System.currentTimeMillis();

		long totalMicros = tic-toc;

		File times = new File("/home/user/workspace/times/weaklyConnectedComponents.txt");
		BufferedWriter bw = new BufferedWriter(new FileWriter(times, true));
		bw.write(totalMicros +" ms\n");
		bw.close();

		File outputs = new File("/home/user/workspace/outputs/weaklyConnectedComponents.txt");
		BufferedWriter bw2 = new BufferedWriter(new FileWriter(outputs));
		for (Vertex<Integer, Integer> vertex : components) {
			bw2.write(vertex.getId() + " " + vertex.getValue() + "\n");
		}
		bw2.close();
	}
}
