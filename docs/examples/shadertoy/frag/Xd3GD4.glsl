
precision highp float;


/// @ref https://www.shadertoy.com/view/Xd3GD4

// no defines, standard redish flames
//#define BLUE_FLAME
//#define GREEN_FLAME

uniform vec2      iResolution;           // viewport resolution (in pixels)
uniform float     iTime;                 // shader playback time (in seconds)

//////////////////////
// Fire Flame shader

// procedural noise from IQ
vec2 hash( vec2 p ) {
	
	p = vec2( dot(p,vec2(127.1,311.7)),
			 dot(p,vec2(269.5,183.3)) );
			 
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
	
}

float noise( in vec2 p ) {
	
	const float K1 = 0.366025404; // (sqrt(3)-1)/2;
	const float K2 = 0.211324865; // (3-sqrt(3))/6;
	
	vec2 i = floor( p + (p.x+p.y)*K1 );
	
	vec2 a = p - i + (i.x+i.y)*K2;
	vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0);
	vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;
	
	vec3 h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
	
	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
	
	return dot( n, vec3(70.0) );
	
}

float fbm(vec2 uv) {
	
	float f;
	
	mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );
	f  = 0.5000*noise( uv ); uv = m*uv;
	f += 0.2500*noise( uv ); uv = m*uv;
	f += 0.1250*noise( uv ); uv = m*uv;
	f += 0.0625*noise( uv ); uv = m*uv;
	f = 0.5 + 0.5*f;
	
	return f;
	
}

void main() {
	
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	
	vec2 q = uv;
	
	q.x *= 5.;
	q.y *= 2.;
	
	float strength = floor(q.x+1.);
	float T3 = max(3.,1.25*strength)*iTime;
	
	q.x = mod(q.x,1.)-0.5;
	q.y -= 0.25;
	
	float n = fbm(strength*q - vec2(0,T3));
	float c = 1. - 16. * pow( max( 0., length(q*vec2(1.8+q.y*1.5,.75) ) - n * max( 0., q.y+.25 ) ),1.2 );
//	float c1 = n * c * (1.5-pow(1.25*uv.y,4.));
	float c1 = n * c * (1.5-pow(2.50*uv.y,4.));
	c1=clamp(c1,0.,1.);


	vec3 col = vec3(1.5*c1, 1.5*c1*c1*c1, c1*c1*c1*c1*c1*c1);
	col= mix(col, pow(vec3(1.-clamp(c1, -1., 0.)) * pow(fbm(strength*q*1.25 - vec2(0,T3)),2.),vec3(2.)), .75-(col.x+col.y+col.z)/3.); // Just added this line!!! :)
	
#ifdef BLUE_FLAME
	col = col.zyx;
#endif
#ifdef GREEN_FLAME
	col = 0.85*col.yxz;
#endif
	
	float a = c * (1.-pow(uv.y,3.));
	
	gl_FragColor = vec4( mix(vec3(0.),col,a), 1.0);
	
}


