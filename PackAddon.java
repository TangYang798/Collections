import java.io.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * Pack an addon package with a patch file
 * <p>
 * Attention:
 * 1. For deleted files and files in project root, DO NOT export to patch file.
 */
public class PackAddon {

    public static String workspacePath = ".";
    public static String projectName = "r";
    public static String webAppPath = "WebContent";
    public static String srcPrefix = "src";
    public static String webAppName = projectName;
    public static String projectPath = workspacePath + "/" + projectName;
    public static String patchFile = workspacePath + "/patch_" + projectName;
    public static String classesPath = projectPath + "/" + webAppPath + "/WEB-INF/classes";
    public static String suffix;

    public static void main(String[] args) throws IOException {
//        if (args.length < 1) {
//            System.out.println("There are 7 parameters.\n" +
//                    "You must input at least 1 parameter: projectName(folder name).\n" +
//                    "workspacePath: default current folder;\n" +
//                    "webAppName: webapp name, default projectName;\n" +
//                    "patchFile: default under workspace name patch_projectName;\n" +
//                    "webAppPath: WebContent folder name, default WebContent;\n" +
//                    "classesPath: compiler output folder, default webAppPath/WEB-INF/classes;\n" +
//                    "srcPrefix: Java source, default src.\n" +
//                    "Output are projectName_date.zip and projectName_date.txt under workspace.");
//            System.exit(2);
//        }
        Date now = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("_yyyy-MM-dd"); // HH-mm-ss
        suffix = sdf.format(now);
        String basePath = workspacePath + "/" + webAppName + "_addon";
        copyFiles(getPatchFileList(), basePath);
        pack(workspacePath + "/" + projectName + suffix + ".zip", basePath);
        deleteFolder(basePath);
    }

    private static void deleteFolder(String basePath) {
        File srcFile = new File(basePath);
        if (srcFile.isDirectory()) {
            File[] files = srcFile.listFiles();
            for (File file : files) {
                deleteFolder(file.getPath());
            }
            srcFile.delete();
        } else {
            srcFile.delete();
        }
    }

    private static List<String> getPatchFileList() throws IOException {
        String changeList = workspacePath + "/" + projectName + suffix + ".txt";
        File changes = new File(changeList);
        if (changes.exists()) {
            changes.delete();
        }
        List<String> fileList = new ArrayList<>();
        String line;
        try (FileInputStream fis = new FileInputStream(patchFile);
             BufferedReader br = new BufferedReader(new InputStreamReader(fis));
             FileOutputStream fos = new FileOutputStream(changes, true)) {
            while ((line = br.readLine()) != null) {
                if (line.startsWith("Index:")) {
                    line = line.substring(line.indexOf(":") + 2, line.length());
                    fileList.add(line);
                    fos.write((projectName + "/" + line + "\n").getBytes());
                    fos.flush();
                }
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
                srcFileName = projectPath + "/" + webAppPath + fileName;
                desFileName += fileName;
            }

            String desFilePathStr = desFileName.substring(0, desFileName.lastIndexOf("/"));
            File desFilePath = new File(desFilePathStr);
            if (!desFilePath.exists()) {
                desFilePath.mkdirs();
            }
            File srcFile = new File(srcFileName);
            File desFile = new File(desFileName);
            try (BufferedInputStream bis = new BufferedInputStream(new FileInputStream(srcFile));
                 BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(desFile))) {
                transfer(bis, bos);
            }
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
        File srcFile = new File(basePath);
        try (ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(desFilePath))) {
            zipCompress(zos, srcFile);
        }
    }

    private static void zipCompress(ZipOutputStream zos, File srcFile) throws IOException {
        String basePath = srcFile.getPath();
        if (srcFile.isDirectory()) {
            File[] files = srcFile.listFiles();
            if (files.length == 0)
                zos.putNextEntry(new ZipEntry(delPreSuffix(basePath)));
            for (File file : files) {
                zipCompress(zos, file);
            }
        } else {
            zos.putNextEntry(new ZipEntry(delPreSuffix(basePath)));
            try (FileInputStream fis = new FileInputStream(srcFile);
                 BufferedInputStream bis = new BufferedInputStream(fis)) {
                transfer(bis, zos);
            }
        }
    }

    private static String delPreSuffix(String basePath) {
        return basePath.replace(workspacePath, "").replace("_addon", "");
    }
}
