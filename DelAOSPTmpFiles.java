/**
* find ~/.jenkins/workspace/Lineage/.repo -type f -name 'tmp_pa*' -delete
*/

import java.io.File;
import java.io.BufferedReader;
import java.io.InputStreamReader;

public class DelAOSPTmpFiles{
    public static void main(String[] args) throws Exception{
        Runtime.getRuntime().exec("sudo updatedb").waitFor();
        Process p = Runtime.getRuntime().exec("locate tmp_pa");
        BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
        String str=br.readLine();
	if(str != null){
		for(; str!=null; str=br.readLine()){
            System.out.print(str + "\t");
            System.out.println(new File(str).delete());//true false
        }
	}else{
		System.out.println("no target file");
	}
	System.out.println("finished");
        br.close();
        p.destroy();
    }
}
