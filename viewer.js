document.addEventListener("DOMContentLoaded", () => {
	const urlParams = new URLSearchParams(window.location.search);
	const target = urlParams.get("target") || "chloride.chlorine.me:49130";
	const statusBar = document.getElementById("status-bar");
	const canvas = document.getElementById("chloride-canvas");
	const ctx = canvas.getContext("2d");

	let cleanTarget = decodeURIComponent(target);
	cleanTarget = cleanTarget.replace(/^ext\+chloride:(?:\/\/)?/i, "");
	cleanTarget = cleanTarget.replace(/\/.*$/, "");

	const [host, portStr] = cleanTarget.split(":");
	const port = parseInt(portStr || "49130", 10);

	statusBar.textContent = `Connecting via Native Host to ${host}:${port}...`;

	let currentWidth = parseInt(urlParams.get("width") || "320", 10);
	let currentHeight = parseInt(urlParams.get("height") || "240", 10);
	canvas.width = currentWidth;
	canvas.height = currentHeight;

	let imageData = ctx.createImageData(currentWidth, currentHeight);

	async function runChlorideWasm(wasmBuffer) {
		try {
			let bytes = new Uint8Array(wasmBuffer);
			let offset = 0;
			for (let i = 0; i < bytes.length - 4; i++) {
				if (bytes[i] === 0x00 && bytes[i+1] === 0x61 && bytes[i+2] === 0x73 && bytes[i+3] === 0x6d) {
					offset = i; break;
				}
			}
			if (offset > 0) bytes = bytes.slice(offset);

			let wasmInstance;
			
			const renderToCanvas = (ptr) => {
				if (!wasmInstance || !wasmInstance.exports.memory || ptr < 0) return;
				const mem = new Uint8ClampedArray(wasmInstance.exports.memory.buffer);
				const copyBytes = Math.min(canvas.width * canvas.height * 4, mem.length - ptr);
				if (copyBytes > 0) {
					imageData.data.set(mem.subarray(ptr, ptr + copyBytes));
					ctx.putImageData(imageData, 0, 0);
				}
			};

			const importObject = {
				env: {
					draw_frame: renderToCanvas,
					render_frame: renderToCanvas
				}
			};

			const { instance } = await WebAssembly.instantiate(bytes, importObject);
			wasmInstance = instance;

			const appWidth = wasmInstance.exports.width ? (typeof wasmInstance.exports.width === "function" ? wasmInstance.exports.width() : wasmInstance.exports.width.value) : currentWidth;
			const appHeight = wasmInstance.exports.height ? (typeof wasmInstance.exports.height === "function" ? wasmInstance.exports.height() : wasmInstance.exports.height.value) : currentHeight;

			if (canvas.width !== appWidth || canvas.height !== appHeight) {
				canvas.width = appWidth;
				canvas.height = appHeight;
				imageData = ctx.createImageData(appWidth, appHeight);
			}

			statusBar.textContent = `Running Chloride app from ${target}`;

			if (wasmInstance.exports.main) {
				wasmInstance.exports.main();
			} else if (wasmInstance.exports._start) {
				wasmInstance.exports._start();
			}

			let fbPtr = 0;
			if (wasmInstance.exports.framebuffer) {
				fbPtr = typeof wasmInstance.exports.framebuffer === "function" ? wasmInstance.exports.framebuffer() : wasmInstance.exports.framebuffer.value;
			} else if (wasmInstance.exports.BUFFER) {
				fbPtr = typeof wasmInstance.exports.BUFFER === "function" ? wasmInstance.exports.BUFFER() : wasmInstance.exports.BUFFER.value;
			}

			if (fbPtr) renderToCanvas(fbPtr);

			const tick = wasmInstance.exports.tick || wasmInstance.exports.update || wasmInstance.exports.render;
			if (tick) {
				const loop = () => {
					tick();
					if (fbPtr) renderToCanvas(fbPtr);
					requestAnimationFrame(loop);
				};
				requestAnimationFrame(loop);
			}
		} catch (err) {
			console.error("[chloride] Wasm execution error:", err);
			statusBar.textContent = `Execution Error: ${err.message}`;
		}
	}

	const runtime = typeof browser !== "undefined" ? browser.runtime : chrome.runtime;
	if (!runtime || !runtime.sendNativeMessage) {
		statusBar.textContent = "Error: Native Messaging API unavailable.";
		return;
	}

	runtime.sendNativeMessage("com.superrealchlorine.chloride_host", { host: host, port: port }, (response) => {
		if (runtime.lastError) {
			statusBar.textContent = `Native Host Error: ${runtime.lastError.message}`;
			return;
		}
		if (response && response.status === "ok") {
			const binaryString = atob(response.data);
			const bytes = new Uint8Array(binaryString.length);
			for (let i = 0; i < binaryString.length; i++) {
				bytes[i] = binaryString.charCodeAt(i);
			}
			runChlorideWasm(bytes.buffer);
		} else if (response) {
			statusBar.textContent = `Host Error: ${response.error}`;
		}
	});
});
