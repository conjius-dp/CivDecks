import { readFileSync, writeFileSync } from "fs";

const file = process.argv[2];
let html = readFileSync(file, "utf8");

// Replace Godot's loading screen with our custom one
const css = `<style>
body { background: #000 !important; margin: 0; overflow: hidden; }
#status {
  position: absolute; top: 0; left: 0; width: 100%; height: 100%;
  display: flex; flex-direction: column; align-items: center;
  justify-content: center; background: #000; z-index: 10;
}
#status-splash { max-width: none; }
#status-splash img {
  width: auto; height: auto; max-width: 80vw; max-height: 40vh;
  image-rendering: auto;
}
#status-progress {
  width: 300px; height: 4px; margin-top: 40px;
  appearance: none; -webkit-appearance: none;
  border: none; background: #1a1a1a; border-radius: 2px;
}
#status-progress::-webkit-progress-bar { background: #1a1a1a; border-radius: 2px; }
#status-progress::-webkit-progress-value { background: #d9a633; border-radius: 2px; }
#status-progress::-moz-progress-bar { background: #d9a633; border-radius: 2px; }
#status-notice {
  color: #555; font-family: sans-serif; font-size: 12px;
  margin-top: 16px; letter-spacing: 1px;
}
canvas { background: #000 !important; }
</style>`;
html = html.replace("<head>", `<head><script src="coi-serviceworker.min.js"></script>${css}`);

// Fix progress bar to track 0-100% smoothly
const oldProgress = `'onProgress': function (current, total) {
				if (current > 0 && total > 0) {
					statusProgress.value = current;
					statusProgress.max = total;
				} else {
					statusProgress.removeAttribute('value');
					statusProgress.removeAttribute('max');
				}
			},`;

const newProgress = `'onProgress': function (current, total) {
				if (current > 0 && total > 0) {
					statusProgress.max = total;
					statusProgress.value = current;
				}
			},`;

html = html.replace(oldProgress, newProgress);

// Hide the loading screen once the engine starts
const oldPrint = `'onPrint': function () {`;
const newPrint = `'onPrint': function () {
					var status = document.getElementById('status');
					if (status) { status.style.transition = 'opacity 0.5s'; status.style.opacity = '0'; setTimeout(function() { status.style.display = 'none'; }, 600); }`;

if (html.includes(oldPrint)) {
	html = html.replace(oldPrint, newPrint);
}

writeFileSync(file, html);
console.log("Patched loading screen:", file);
