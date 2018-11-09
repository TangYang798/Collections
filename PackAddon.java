import java.io.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * Pack an addon package with a patch file
 *
 * Attention:
 * 1. For deleted files and files in project root, DO NOT export to patch file.
 * 2. Pay attention to path separator. (In method String delPrefix(String basePath))
 * 3.
 */
public class PackAddon {

    public static String projectPathFS = "/home/young/dev/eclipse-workspace/r";
    public static String patchFileFS = "/home/young/tmp/patch.txt";
    public static String desPathFS = "/home/young/tmp"; // target folder
    public static String webAppPath = "WebContent";
    public static String classesPath = projectPathFS + "/" + webAppPath + "/WEB-INF/classes";
    public static String appName = "ROOT";
    public static String srcPrefix = "src";

    public static void main(String[] args) throws IOException {
        Date now = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("_yyyy-MM-dd"); // HH-mm-ss
        String suffix = sdf.format(now) + ".zip";
        String basePath = desPathFS + "/" + appName;
        copyFiles(getPatchFileList(), basePath);
        pack(desPathFS + "/" + appName + suffix, basePath);
    }

    private static List<String> getPatchFileList() throws IOException {
        List<String> fileList = new ArrayList<>();
        FileInputStream fis = new FileInputStream(patchFileFS);
        BufferedReader br = new BufferedReader(new InputStreamReader(fis));
        String line;
        while ((line = br.readLine()) != null) {
            if (line.startsWith("Index:")) {
                line = line.substring(line.indexOf(":") + 2, line.length());
                fileList.add(line);
            }
        }
        return fileList;
    }

    private static void copyFiles(List<String> fileList, String basePath) throws IOException {
        for (String srcFileName : fileList) {
            String desFileName = basePath;
            String fileName = "";
            if (srcFileName.indexOf(srcPrefix) != -1) {
                fileName = srcFileName.replace(srcPrefix, "").replace(".java", ".class");
                srcFileName = classesPath + fileName;
                desFileName += "/WEB-INF/classes" + fileName;
            } else if (srcFileName.indexOf(webAppPath) != -1) {
                fileName = srcFileName.replace(webAppPath, "");
                srcFileName = projectPathFS + "/" + webAppPath + fileName;
                desFileName += fileName;
            }

            String desFilePathStr = desFileName.substring(0, desFileName.lastIndexOf("/"));
            File desFilePath = new File(desFilePathStr);
            if (!desFilePath.exists()) {
                desFilePath.mkdirs();
            }
            File srcFile = new File(srcFileName);
            File desFile = new File(desFileName);
            BufferedInputStream bis = null;
            BufferedOutputStream bos = null;
            try {
                bis = new BufferedInputStream(new FileInputStream(srcFile));
                bos = new BufferedOutputStream(new FileOutputStream(desFile));
                transfer(bis, bos);
            } finally {
                closeResources(new InputStream[]{bis}, new OutputStream[]{bos});
            }
            System.out.println(desFileName);
        }
    }

    private static void closeResources(InputStream[] iss, OutputStream[] oss) throws IOException {
        if (oss != null) {
            for (OutputStream os : oss)
                if (os != null)
                    os.close();
        }
        if (iss != null) {
            for (InputStream is : iss)
                if (is != null)
                    is.close();
        }
    }

    private static void transfer(InputStream is, OutputStream os) throws IOException {
        byte[] b = new byte[1024 * 5];
        int len;
        while ((len = is.read(b)) != -1) {
            os.write(b, 0, len);
        }
        os.flush();
    }

    private static void pack(String desFilePath, String basePath) throws IOException {
        ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(desFilePath));
        BufferedOutputStream bos = new BufferedOutputStream(zos);
        File srcFile = new File(basePath);
        zipCompress(zos, bos, srcFile);
        closeResources(null, new OutputStream[] {bos, zos});
    }

    private static void zipCompress(ZipOutputStream zos, BufferedOutputStream bos, File srcFile) throws IOException {
        String basePath = srcFile.getPath();
        if (srcFile.isDirectory()) {
            File[] files = srcFile.listFiles();
            if (files.length == 0)
                zos.putNextEntry(new ZipEntry(delPrefix(basePath)));
            for (File file : files) {
                zipCompress(zos, bos, file);
            }
        } else {
            zos.putNextEntry(new ZipEntry(delPrefix(basePath)));
            FileInputStream fis = new FileInputStream(srcFile);
            BufferedInputStream bis = new BufferedInputStream(fis);
            transfer(bis, zos);
            closeResources(new InputStream[] {bis, fis}, null);
        }
    }

    private static String delPrefix(String basePath) {
        return basePath.replace(desPathFS, "");
    }
}
