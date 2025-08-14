(function(){

const character = document.querySelector('[data-anim="character"]') || document.querySelector('#ryan');
const face = character ? character.querySelectorAll('.ears, .eyes, .muzzle') : [];
const email = document.querySelector('#userId');
const password = document.querySelector('#password');
const fauxInput = document.createElement('div');
const span = document.createElement('span');
let timer = null;

function rotate3d(x, y, z, rad) {
    const value = `rotate3d(${x}, ${y}, ${z}, ${rad}rad)`;
    for (let i=0; i < face.length; i++) {
        face[i].style.transform = value;
    }
}

function focus(event) {
    event.target.classList.add('focused');
    copyStyles(event.target);
    event.target.type === 'password' ? lookAway(event) : look(event);
}

function reset(event) {
    event.target.classList.remove('focused');
    if (!character) return;
    character.classList.remove('playing');

    clearTimeout(timer);
    timer = setTimeout( () => {
        character.classList.remove('look-away', 'down', 'up');
        rotate3d(0,0,0,0);
    }, 1 );
}

function copyStyles(el) {
    const props = window.getComputedStyle(el, null);

    if ( fauxInput.parentNode === document.body ) {
        document.body.removeChild(fauxInput);
    }

    fauxInput.style.visibility = 'hidden';
    fauxInput.style.position = 'absolute';
    fauxInput.style.top = Math.min(el.offsetHeight * -2, -999) + 'px';

    for(let i=0; i < props.length; i++) {
        if (['visibility','display','opacity','position','top','left','right','bottom'].indexOf(props[i]) !== -1) {
            continue;
        }
        fauxInput.style[props[i]] = props.getPropertyValue(props[i]);
    }

    document.body.appendChild(fauxInput);
}

function look(event) {
    const el = event.target;
    const text = el.value.substr(0, el.selectionStart);

    span.innerText = text || '.';

    if (!character) return;
    const ryanRect = character.getBoundingClientRect();
    const inputRect = el.getBoundingClientRect();
    const caretRect = span.getBoundingClientRect();
    const caretPos = inputRect.left + Math.min(caretRect.width, inputRect.width) * !!text;
    const distCaret = ryanRect.left + ryanRect.width/2 - caretPos;
    const distInput = ryanRect.top + ryanRect.height/2 - inputRect.top;
    const y = Math.atan2(-distCaret, Math.abs(distInput)*3);
    const x =  Math.atan2(distInput, Math.abs(distInput)*3 / Math.cos(y));
    const angle = Math.max(Math.abs(x), Math.abs(y));

    rotate3d(x/angle, y/angle, y/angle/2, angle);
}

function lookAway(event) {
    const el = event.target;
    if (!character) return;
    const ryanRect = character.getBoundingClientRect();
    const inputRect = el.getBoundingClientRect();
    const distInput = ryanRect.top + ryanRect.height/2 - inputRect.top;

    character.classList.add( 'look-away', distInput < 0 ? 'up' : 'down' );

    clearTimeout(timer);
    timer = setTimeout( () => {
        character.classList.add( 'playing' );
    }, 300);
}

fauxInput.appendChild(span);

email && email.addEventListener( 'focus', focus, false );
email && email.addEventListener( 'keyup', look, false );
email && email.addEventListener( 'click', look, false );
email && email.addEventListener( 'blur', reset, false );

password && password.addEventListener( 'focus', lookAway, false );
password && password.addEventListener( 'blur', reset, false );

})();