defaultCSS = [[
@keyframes flash {
    from { 
        background-color: #ff4500ff;
        box-shadow: 0px 0px 0.5em #ff4500ff;
    }
    to { 
        background-color: #ff450000;
        box-shadow: 0px 0px 0.5em #ff450000;
    }
}
.wrap {
    color: white;
    text-shadow: 0 0 0.2em #000000aa;
    vertical-align: middle;
    padding: 1em;
}
.state {
    display: inline-block;
    height: 1em;
    width: 1em;
    border-radius: 50%;
    float: right;
}
.state.true { background-color: greenyellow; }
.state.false { background-color: red; }
.sub { font-size: 0.3em; vertical-align: middle; }
.warning { 
    animation: 200ms normal linear infinite;
    animation-name: flash;
    margin: 0.1em;
    padding: 0.5em 0.25em;
    text-align: center;
    margin-top: 0.5em;
    color: white;
}
hk::before { content: '['; vertical-align: top; }
hk::after { content: ']'; vertical-align: top; }
hk { 
    font-size: 0.85em; 
    text-transform: lowercase; 
    vertical-align: top;
    color: aqua;
    display: inline;
}
p {
    text-transform: uppercase;
    margin-top: 0.1em;
    margin-bottom: 0;
}
.keys { margin-top: 1em; }
.keys span { margin: 0; text-transform: uppercase; }
.stats, .stats p { font-size: 0.85em; }]]