/**
* Override Decidim's editor so it is not executed.does not modify our config.
*/
import {destroyQuillEditor, createQuillEditor, createMarkdownEditor} from "./decidim_awesome/editors/editor.js";

export {destroyQuillEditor, createQuillEditor, createMarkdownEditor};
export default createQuillEditor;