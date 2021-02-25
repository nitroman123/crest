﻿// Crest Ocean System

// This file is subject to the MIT License as seen in the root of this folder structure (LICENSE)

Shader "Crest/Inputs/Dynamic Waves/Capsule-Water Interaction"
{
	Properties
	{
		_Strength("Strength", Range(0.0, 10.0)) = 0.2
		_StrengthVertical("Vertical Strength Multiplier", Range(0.0, 1.0)) = 1.0
		_CylindricalLength("Cylindrical Length", Float) = 1.0
	}

	SubShader
	{
		Pass
		{
			Blend One One
			ZTest Always
			ZWrite Off
			
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"

			#include "../OceanGlobals.hlsl"

			CBUFFER_START(CrestPerOceanInput)
			float3 _Velocity;
			float _SimDeltaTime;
			float _Strength;
			float _StrengthVertical;
			float _Weight;
			float _Radius;
			float3 _DisplacementAtInputPosition;
			CBUFFER_END

			float _MinWavelength;
			float _LodIdx;

			struct Attributes
			{
				float3 positionOS : POSITION;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float2 offsetXZ : TEXCOORD0;
				float3 pointOnWaterPlane : TEXCOORD1;
			};

			Varyings Vert(Attributes input)
			{
				Varyings o;

				const float quadExpand = 4.0;

				float3 vertexWorldPos = mul(unity_ObjectToWorld, float4(input.positionOS * quadExpand, 1.0));
				float3 centerPos = unity_ObjectToWorld._m03_m13_m23;

				o.offsetXZ = vertexWorldPos.xz - centerPos.xz;

				// Correct for displacement
				vertexWorldPos.xz -= _DisplacementAtInputPosition.xz;

				o.positionCS = mul(UNITY_MATRIX_VP, float4(vertexWorldPos, 1.0));

				o.pointOnWaterPlane = vertexWorldPos;
				o.pointOnWaterPlane.y = _OceanCenterPosWorld.y;

				if( _Radius < _MinWavelength ) o.positionCS *= 0.0;

				return o;
			}

			// Resolution-aware interaction falloff function, inspired by "bandfiltered step" from Ottosson.
			// Basically adding together this falloff function at different scales generates a consistent result
			// that doesn't grow into an ugly uintended shape. Shadertoy with more details: https://www.shadertoy.com/view/WltBWM
			float InteractionFalloff( float a, float x )
			{
				float ax = a * x;
				float ax2 = ax * ax;
				float ax4 = ax2 * ax2;
				
				return ax / (1.0 + ax2 * ax4);
			}

			// Signed distance field for sphere.
			void SphereSDF( float2 offsetXZ, out float signedDist, out float2 normal )
			{
				float dist = length( offsetXZ );
				signedDist = dist - _Radius;
				normal = dist > 0.0001 ? offsetXZ / dist : float2(1.0, 0.0);
			}

			void SphereSDF2(float3 center, float radius, float3 p, out float signedDist, out float3 normal)
			{
				float3 offset = p - center;
				float dist = length(offset);
				signedDist = dist - radius;
				normal = (dist > 0.0001) ? (offset / dist) : float3(0.0, -1.0, 0.0);
			}

			/*void CapsuleSDF(float2 offsetXZ, out float signedDist, out float2 normal)
			{
				float2 
			}*/

			half4 Frag(Varyings input) : SV_Target
			{
				// Compute signed distance to sphere (sign gives inside/outside), and outwards normal to sphere surface
				float signedDist;
				float3 sdfNormal;
				SphereSDF2(unity_ObjectToWorld._m03_m13_m23, _Radius, input.pointOnWaterPlane, signedDist, sdfNormal);

				//SphereSDF(input.offsetXZ, signedDist, sdfNormal);

				// Forces from up/down motion. Push in same direction as vel inside sphere, and opposite dir outside.
				float forceUpDown = 0.0;
				{
					forceUpDown = -5.0 * _StrengthVertical * _Velocity.y;
					if( signedDist > 0.0 );// && _Radius < 8.0 * _MinWavelength )
					{
						//forceUpDown *= -exp(-signedDist * signedDist * 4.0);
						// Range / radius of interaction force
						const float range = 0.6 * _MinWavelength;
						const float a = 1.0 / range;
						forceUpDown *= InteractionFalloff( a, signedDist );
					}

				}

				// Forces from horizontal motion - push water up in direction of motion, pull down behind.
				float forceHoriz = 0.0;
				if( signedDist > 0.0 )
				{
					// Range / radius of interaction force
					const float range = 0.7 * _MinWavelength;
					const float a = 1.0 / range;
					forceHoriz = 0.75 * dot( sdfNormal.xz, _Velocity.xz ) * InteractionFalloff( a, signedDist );
				}

				// Add to velocity (y-channel) to accelerate water.
				return _Weight * half4(0.0, (forceUpDown + forceHoriz) * _SimDeltaTime * _Strength, 0.0, 0.0);
			}
			ENDCG
		}
	}
}