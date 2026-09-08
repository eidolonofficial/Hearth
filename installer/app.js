const form = document.querySelector('#install-form');
const previewButton = document.querySelector('#preview-btn');
const installButton = document.querySelector('#install-btn');
const status = document.querySelector('#status');
const preview = document.querySelector('#preview');
let token = '';
let reviewedFingerprint = '';

const values = () => ({
  host: new FormData(form).get('host'),
  project: document.querySelector('#project').value.trim(),
  replace: document.querySelector('#replace').checked
});
const fingerprint = value => JSON.stringify(value);
function setStatus(message = '', tone = '') {
  status.textContent = message;
  status.className = `status ${tone}`.trim();
}
function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
}
async function api(path, payload) {
  const response = await fetch(path, {
    method: 'POST',
    headers: {'content-type':'application/json','x-hearth-token':token},
    body: JSON.stringify(payload)
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(data.error || `Request failed (${response.status})`);
  return data;
}
async function loadSession() {
  try {
    const response = await fetch('/api/session', {cache:'no-store'});
    const data = await response.json();
    token = data.token;
  } catch {
    setStatus('Hearth could not reach its local installer service. Close this window and start Hearth again.', 'error');
    previewButton.disabled = true;
  }
}
function invalidateReview() {
  if (reviewedFingerprint && reviewedFingerprint !== fingerprint(values())) {
    reviewedFingerprint = '';
    installButton.disabled = true;
    preview.hidden = true;
    setStatus('Review the updated plan before installing.');
  }
}
form.addEventListener('input', invalidateReview);
form.addEventListener('change', invalidateReview);

previewButton.addEventListener('click', async () => {
  previewButton.disabled = true;
  installButton.disabled = true;
  preview.hidden = true;
  setStatus('Preparing a read-only preview…');
  const request = values();
  try {
    const data = await api('/api/preview', request);
    reviewedFingerprint = fingerprint(request);
    const paths = (data.paths || []).map(path => `<li>${escapeHtml(path)}</li>`).join('');
    preview.innerHTML = `<h3>Hearth will prepare</h3><ul>${paths}</ul>${request.replace ? '<p class="backup-note">Existing skill folders may be replaced only after a backup is created.</p>' : ''}`;
    preview.hidden = false;
    installButton.disabled = false;
    setStatus('Nothing has been written. Review the paths, then install when you are ready.', 'good');
  } catch (error) {
    setStatus(error.message, 'error');
  } finally {
    previewButton.disabled = false;
  }
});

form.addEventListener('submit', async event => {
  event.preventDefault();
  const request = values();
  if (reviewedFingerprint !== fingerprint(request)) {
    installButton.disabled = true;
    setStatus('Review this exact plan before installing.', 'error');
    return;
  }
  installButton.disabled = true;
  previewButton.disabled = true;
  setStatus('Installing. Hearth is staging and verifying the complete bundle before it changes a destination…');
  try {
    const data = await api('/api/install', {...request, confirm:true});
    const backup = data.backups ? ` Backup receipt: ${data.backups}` : '';
    setStatus(`Installed and verified ${data.changed ?? 0} change${data.changed === 1 ? '' : 's'}.${backup}`, 'good');
    installButton.textContent = 'Installed';
    reviewedFingerprint = '';
    celebrate();
  } catch (error) {
    setStatus(error.message, 'error');
    installButton.disabled = false;
  } finally {
    previewButton.disabled = false;
  }
});

function celebrate() {
  document.documentElement.animate([
    {filter:'brightness(1)'},
    {filter:'brightness(1.045)'},
    {filter:'brightness(1)'}
  ], {duration:900, easing:'ease-out'});
}

async function enhanceScene() {
  const canvas = document.querySelector('#hearth-scene');
  if (!canvas || matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  try {
    const THREE = await import('https://cdn.jsdelivr.net/npm/three@0.180.0/build/three.module.js');
    const renderer = new THREE.WebGLRenderer({canvas, antialias:true, alpha:true, powerPreference:'low-power'});
    renderer.setPixelRatio(Math.min(devicePixelRatio, 1.7));
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.05;
    const scene3d = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(36, 1, .1, 100);
    camera.position.set(0, 0, 8.5);

    const group = new THREE.Group();
    group.position.set(.35, -.05, 0);
    scene3d.add(group);

    const loader = new THREE.TextureLoader();
    const lanternTexture = await loader.loadAsync('/assets/lantern.svg');
    lanternTexture.colorSpace = THREE.SRGBColorSpace;
    const lantern = new THREE.Sprite(new THREE.SpriteMaterial({map:lanternTexture, transparent:true, depthWrite:false}));
    lantern.scale.set(3.05, 3.82, 1);
    lantern.position.set(.9, -.15, .2);
    group.add(lantern);

    const logoTexture = await loader.loadAsync('/assets/EidolonLogo.png');
    logoTexture.colorSpace = THREE.SRGBColorSpace;
    const logo = new THREE.Sprite(new THREE.SpriteMaterial({map:logoTexture, transparent:true, opacity:.26, depthWrite:false}));
    logo.scale.set(2.55, 2.55, 1);
    logo.position.set(-1.45, .42, -1.2);
    group.add(logo);

    const glowMaterial = new THREE.MeshBasicMaterial({color:0xf3a34d, transparent:true, opacity:.11, blending:THREE.AdditiveBlending, depthWrite:false});
    const glow = new THREE.Mesh(new THREE.SphereGeometry(1.12, 32, 32), glowMaterial);
    glow.position.set(.9, -.05, -.4);
    group.add(glow);

    const tealGlow = new THREE.Mesh(new THREE.SphereGeometry(.45, 24, 24), new THREE.MeshBasicMaterial({color:0x65b8ad,transparent:true,opacity:.06,blending:THREE.AdditiveBlending,depthWrite:false}));
    tealGlow.position.set(-1.2,.4,-1);
    group.add(tealGlow);

    const count = 94;
    const positions = new Float32Array(count * 3);
    const sizes = new Float32Array(count);
    for (let i=0;i<count;i++) {
      positions[i*3] = (Math.random()-.5)*8;
      positions[i*3+1] = (Math.random()-.5)*7;
      positions[i*3+2] = -1.8 + Math.random()*4;
      sizes[i] = .7 + Math.random()*1.8;
    }
    const dustGeo = new THREE.BufferGeometry();
    dustGeo.setAttribute('position', new THREE.BufferAttribute(positions,3));
    const dust = new THREE.Points(dustGeo, new THREE.PointsMaterial({color:0xf1c078,size:.026,transparent:true,opacity:.43,sizeAttenuation:true,depthWrite:false}));
    scene3d.add(dust);

    let mx = 0, my = 0;
    window.addEventListener('pointermove', event => {
      mx = (event.clientX / innerWidth - .5) * .12;
      my = (event.clientY / innerHeight - .5) * .08;
    }, {passive:true});
    const clock = new THREE.Clock();
    function resize() {
      const rect = canvas.getBoundingClientRect();
      renderer.setSize(rect.width, rect.height, false);
      camera.aspect = rect.width / Math.max(rect.height,1);
      camera.updateProjectionMatrix();
    }
    new ResizeObserver(resize).observe(canvas); resize();
    function frame() {
      const t = clock.getElapsedTime();
      group.rotation.y += (mx - group.rotation.y) * .018;
      group.rotation.x += (-my - group.rotation.x) * .018;
      lantern.position.y = -.15 + Math.sin(t*.72)*.028;
      glow.scale.setScalar(1 + Math.sin(t*2.1)*.045);
      glowMaterial.opacity = .105 + Math.sin(t*2.35)*.018;
      dust.rotation.z = t * .006;
      dust.position.y = Math.sin(t*.18)*.05;
      renderer.render(scene3d,camera);
      requestAnimationFrame(frame);
    }
    frame();
  } catch (error) {
    console.info('Hearth cinematic layer unavailable; using static fallback.', error);
  }
}

loadSession();
enhanceScene();
