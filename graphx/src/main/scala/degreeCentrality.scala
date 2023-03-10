import java.io._
import org.apache.spark._
import org.apache.spark.rdd.RDD
import org.apache.spark.graphx._
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.storage.StorageLevel

object degreeCentrality {
    def main(args: Array[String]): Unit = {
        
        // Create a Spark configuration and context
        val conf = new SparkConf()
            .setAppName("degreeCentrality")
            .setMaster("spark://master:7077")
        val sc = new SparkContext(conf)

        val path = "hdfs://master:9000/user/user/data/web-Google.txt"

        // Load the edges as a graph
        val graph: Graph[Int, Int] = GraphLoader.edgeListFile(
            sc,
            path,
            edgeStorageLevel = StorageLevel.MEMORY_AND_DISK,
            vertexStorageLevel = StorageLevel.MEMORY_AND_DISK
        )

        // Compute the degree centrality and time the operation
        val startTime = System.currentTimeMillis()
        val degreeCentrality = graph.degrees.mapValues(d => d.toInt).collect().map{
            case (id, deg) => s"$id $deg"
        }
        val endTime = System.currentTimeMillis()

        // Write the results to seperate files for time and data
        val timeTakenStr = s"${endTime - startTime} ms"

        val times = new File("/home/user/graphx/times/degreeCentrality.txt")
        val bw = new BufferedWriter(new FileWriter(times, true))
        bw.write(timeTakenStr + "\n")
        bw.close()
        
        val outputs = new File("/home/user/graphx/outputs/degreeCentrality.txt")
        val bw2 = new BufferedWriter(new FileWriter(outputs))
        bw2.write(degreeCentrality.mkString("\n"))
        bw2.write("\n")
        bw2.close()

        // Stop the Spark context
        sc.stop()
    }
}
