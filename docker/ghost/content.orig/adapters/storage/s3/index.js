"use strict";
var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/index.ts
var src_exports = {};
__export(src_exports, {
  default: () => src_default
});
module.exports = __toCommonJS(src_exports);
var import_client_s3 = require("@aws-sdk/client-s3");
var import_ghost_storage_base = __toESM(require("ghost-storage-base"));
var import_path = require("path");
var import_promises = require("fs/promises");
var stripLeadingSlash = (s) => s.indexOf("/") === 0 ? s.substring(1) : s;
var stripEndingSlash = (s) => s.indexOf("/") === s.length - 1 ? s.substring(0, s.length - 1) : s;
var S3Storage = class extends import_ghost_storage_base.default {
  constructor(config = {}) {
    super();
    const {
      accessKeyId,
      assetHost,
      bucket,
      pathPrefix,
      region,
      secretAccessKey,
      endpoint,
      forcePathStyle,
      acl
    } = config;
    this.accessKeyId = accessKeyId;
    this.secretAccessKey = secretAccessKey;
    this.region = process.env.AWS_DEFAULT_REGION || region;
    this.bucket = process.env.GHOST_STORAGE_ADAPTER_S3_PATH_BUCKET || bucket;
    if (!this.bucket)
      throw new Error("S3 bucket not specified");
    this.host = process.env.GHOST_STORAGE_ADAPTER_S3_ASSET_HOST || assetHost || `https://s3${this.region === "us-east-1" ? "" : `-${this.region}`}.amazonaws.com/${this.bucket}`;
    this.pathPrefix = stripLeadingSlash(
      process.env.GHOST_STORAGE_ADAPTER_S3_PATH_PREFIX || pathPrefix || ""
    );
    this.endpoint = process.env.GHOST_STORAGE_ADAPTER_S3_ENDPOINT || endpoint || "";
    this.forcePathStyle = Boolean(process.env.GHOST_STORAGE_ADAPTER_S3_FORCE_PATH_STYLE) || Boolean(forcePathStyle) || false;
    this.acl = process.env.GHOST_STORAGE_ADAPTER_S3_ACL || acl || "public-read";
  }
  async delete(fileName, targetDir) {
    const directory = targetDir || this.getTargetDir(this.pathPrefix);
    try {
      await this.s3().deleteObject({
        Bucket: this.bucket,
        Key: stripLeadingSlash((0, import_path.join)(directory, fileName))
      });
    } catch {
      return false;
    }
    return true;
  }
  async exists(fileName, targetDir) {
    try {
      await this.s3().getObject({
        Bucket: this.bucket,
        Key: stripLeadingSlash(
          targetDir ? (0, import_path.join)(targetDir, fileName) : fileName
        )
      });
    } catch {
      return false;
    }
    return true;
  }
  s3() {
    const options = {
      region: this.region,
      forcePathStyle: this.forcePathStyle
    };
    if (this.accessKeyId && this.secretAccessKey) {
      options.credentials = {
        accessKeyId: this.accessKeyId,
        secretAccessKey: this.secretAccessKey
      };
    }
    if (this.endpoint !== "") {
      options.endpoint = this.endpoint;
    }
    return new import_client_s3.S3(options);
  }
  // Doesn't seem to be documented, but required for using this adapter for other media file types.
  // Seealso: https://github.com/laosb/ghos3/pull/6
  urlToPath(url) {
    if (URL.canParse(url)) {
      return new URL(url).pathname;
    }
    return url;
  }
  async save(image, targetDir) {
    let directory = targetDir || this.getTargetDir(this.pathPrefix);
    const [fileName, file] = await Promise.all([
      this.getUniqueFileName(image, directory),
      (0, import_promises.readFile)(image.path)
    ]);
    let config = {
      ACL: this.acl,
      Body: file,
      Bucket: this.bucket,
      CacheControl: `max-age=${30 * 24 * 60 * 60}`,
      ContentType: image.type,
      Key: stripLeadingSlash(fileName)
    };
    await this.s3().putObject(config);
    return `${this.host}/${fileName}`;
  }
  serve() {
    return async (req, res, next) => {
      try {
        const output = await this.s3().getObject({
          Bucket: this.bucket,
          Key: stripLeadingSlash(stripEndingSlash(this.pathPrefix) + req.path)
        });
        const headers = {};
        if (output.AcceptRanges)
          headers["accept-ranges"] = output.AcceptRanges;
        if (output.CacheControl)
          headers["cache-control"] = output.CacheControl;
        if (output.ContentDisposition)
          headers["content-disposition"] = output.ContentDisposition;
        if (output.ContentEncoding)
          headers["content-encoding"] = output.ContentEncoding;
        if (output.ContentLanguage)
          headers["content-language"] = output.ContentLanguage;
        if (output.ContentLength)
          headers["content-length"] = `${output.ContentLength}`;
        if (output.ContentRange)
          headers["content-range"] = output.ContentRange;
        if (output.ContentType)
          headers["content-type"] = output.ContentType;
        if (output.ETag)
          headers["etag"] = output.ETag;
        res.set(headers);
        const stream = output.Body;
        stream.pipe(res);
      } catch (err) {
        res.status(404);
        next(err);
      }
    };
  }
  async read(options = { path: "" }) {
    let path = (options.path || "").replace(/\/$|\\$/, "");
    if (!path.startsWith(this.host)) {
      throw new Error(`${path} is not stored in s3`);
    }
    path = path.substring(this.host.length);
    const response = await this.s3().getObject({
      Bucket: this.bucket,
      Key: stripLeadingSlash(path)
    });
    const stream = response.Body;
    return await new Promise((resolve, reject) => {
      const chunks = [];
      stream.on("data", (chunk) => chunks.push(chunk));
      stream.once("end", () => resolve(Buffer.concat(chunks)));
      stream.once("error", reject);
    });
  }
};
var src_default = S3Storage;
module.exports = module.exports.default;
