const fs = require("fs");
const lowdb = require("lowdb");
const FileSync = require("lowdb/adapters/FileSync");
const mkdirp = require("mkdirp");
const shortid = require("shortid");

const UPLOAD_DIR = "./uploads";
const db = lowdb(new FileSync("db.json"));

// Seed an empty DB.
db.defaults({ uploads: [] }).write();

// Ensure upload directory exists.
mkdirp.sync(UPLOAD_DIR);

const storeFS = ({ stream, filename }) => {
  const id = shortid.generate();
  const path = `${UPLOAD_DIR}/${id}-${filename}`;
  return new Promise((resolve, reject) =>
    stream
      .on("error", error => {
        if (stream.truncated)
          // Delete the truncated file.
          fs.unlinkSync(path);
        reject(error);
      })
      .pipe(fs.createWriteStream(path))
      .on("error", error => reject(error))
      .on("finish", () => resolve({ id, path }))
  );
};

const storeDB = file =>
  db
    .get("uploads")
    .push(file)
    .last()
    .write();

const processUpload = async upload => {
  const { createReadStream, filename, mimetype } = await upload;
  const stream = createReadStream();
  const { id, path } = await storeFS({ stream, filename });
  return storeDB({ id, filename, mimetype, path });
};

module.exports = {
  db,
  processUpload
};
