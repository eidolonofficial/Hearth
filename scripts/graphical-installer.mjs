// Compatibility entry point; one maintained local HTTP implementation.
import {createHearthServer,startHearth} from './hearth-ui.mjs';
import {resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
export {createHearthServer};
if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url))startHearth();
