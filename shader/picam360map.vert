//position is windowed sphere
const int STEPNUM = 64;
const float STEPNUM_M1 = 63.0;
const float STEPNUM_M2 = 62.0;

uniform float material_index;
uniform float frame_scalex;
uniform float frame_scaley;
//angular map params
uniform float pitch_2_r[STEPNUM];

uniform mat4 unif_matrix;

const float M_PI = 3.1415926535;
const float M_PI_DIV_2 = M_PI / 2.0;
const float M_PI_DIV_4 = M_PI / 4.0;
const float M_SQRT_2 = 1.4142135623;

varying vec2 tcoord;

void main(void) {
	float pitch = acos(position.z);
	float roll = atan(position.y, position.x);

	float indexf = pitch / M_PI * STEPNUM_M1;
	int index = int(indexf);
	float index_sub = indexf - float(index);
	float r = pitch_2_r[index] * (1.0 - index_sub) + pitch_2_r[index + 1] * index_sub;
	if (r > 1.0) {
		float roll_base;
		if (material_index == 0.0) {
			roll_base = M_PI_DIV_4;
		} else if (material_index == 1.0) {
			roll_base = M_PI_DIV_2 + M_PI_DIV_4;
			if (roll < 0.0) {
				roll = roll + 2.0 * M_PI;
			}
		} else if (material_index == 2.0) {
			roll_base = -M_PI_DIV_2 - M_PI_DIV_4;
			if (roll > 0.0) {
				roll = roll - 2.0 * M_PI;
			}
		} else if (material_index == 3.0) {
			roll_base = -M_PI_DIV_4;
		} else {
			roll_base = -M_PI_DIV_4;
		}
		float roll_diff = roll - roll_base;
		float roll_gain = (M_PI - 4.0 * acos(1.0 / r)) / M_PI;
		roll = roll_diff * roll_gain + roll_base;
	}

	if (position.z == 1.0) {
		roll = 0.0;
	}
	float tex_x = r * cos(roll); //[-1:1]
	float tex_y = r * sin(roll); //[-1:1]
	tcoord = (vec2(tex_x, tex_y) + vec2(1, 1)) * vec2(0.5, 0.5);
	if (tcoord.x < 0.0) {
		tcoord.x = 0.0;
	} else if (tcoord.x > 1.0) {
		tcoord.x = 1.0;
	}
	if (tcoord.y < 0.0) {
		tcoord.y = 0.0;
	} else if (tcoord.y > 1.0) {
		tcoord.y = 1.0;
	}

	vec4 pos = unif_matrix * vec4(position, 1.0);
	if (pos.z > 0.0) {
		float x = pos.x / pos.z;
		float y = pos.y / pos.z;
		gl_Position = vec4(x * frame_scalex, y * frame_scaley, 1.0, 1.0);
	} else {
		gl_Position = vec4(0, 0, 2.0, 1.0);
	}
}
