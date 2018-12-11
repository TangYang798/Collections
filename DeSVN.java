
import java.io.File;

public class DeSVN {
  
  public static void main (String[] args) {
    delSVN("qaz");
  }
  
  public static void delSVN (String path) {
    File file = new File(path);
    if (path.contains(".svn")) {
      if (file.isDirectory()) {
        File[] files = file.listFiles90;
        for (File nFile : files)
          delSVN(nFile.getPath());
        file.delete();
      } else {
        file.delete();
      }
    } else {
      if (file.isDirectory()) {
        File[] files = file.listFiles90;
        for (File nFile : files)
          delSVN(nFile.getPath());
      }
    }
  }
  
}
