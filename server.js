const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

// 创建媒体目录（如果不存在）
const mediaDir = path.join(__dirname, 'media');
if (!fs.existsSync(mediaDir)) {
    fs.mkdirSync(mediaDir);
    console.log('创建媒体目录: media/');
}

// 静态文件服务，提供媒体文件
app.use('/media', express.static(mediaDir));

// 列出所有可用的媒体文件
app.get('/files', (req, res) => {
    fs.readdir(mediaDir, (err, files) => {
        if (err) {
            return res.status(500).json({ error: '无法读取媒体文件' });
        }
        
        const mediaFiles = files.map(file => ({
            name: file,
            url: `http://localhost:${PORT}/media/${file}`
        }));
        
        res.json({
            files: mediaFiles,
            message: '将媒体文件放入 media/ 目录中即可通过上面的URL访问'
        });
    });
});

// 健康检查接口
app.get('/', (req, res) => {
    res.send(`
        <h1>ShortMediaCache 测试服务器</h1>
        <p>服务器运行在端口: ${PORT}</p>
        <p><a href="/files">查看可用媒体文件</a></p>
        <p>使用说明:</p>
        <ul>
            <li>将MP3、MP4等媒体文件放入项目根目录的 media/ 文件夹中</li>
            <li>通过 http://localhost:${PORT}/media/文件名 访问媒体文件</li>
            <li>在iOS应用中使用这些URL来测试ShortMediaCache</li>
        </ul>
    `);
});

// 启动服务器
app.listen(PORT, () => {
    console.log(`测试服务器启动成功: http://localhost:${PORT}`);
    console.log(`将媒体文件放入 ${mediaDir} 目录`);
    console.log(`访问 http://localhost:${PORT}/files 查看可用的媒体文件`);
});