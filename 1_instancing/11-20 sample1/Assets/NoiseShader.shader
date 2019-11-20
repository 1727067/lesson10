Shader "Custom/NoiseShader"
{
    Properties
    {
    }
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest always

        Pass
        {
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed2 random2(float2 st) {
                st = float2(dot(st, fixed2(127.1, 311.7)),
                    dot(st, fixed2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            float Noise(float2 st)
            {
                float2 p = floor(st);
                float2 f = frac(st);
                float2 u = f * f * (3.0 - 2.0 * f);

                return lerp(
                    lerp(dot(random2(p + float2(0.0, 0.0)), f - float2(0.0, 0.0)),
                         dot(random2(p + float2(1.0, 0.0)), f - float2(1.0, 0.0)), u.x),
                    lerp(dot(random2(p + float2(0.0, 1.0)), f - float2(0.0, 1.0)),
                         dot(random2(p + float2(1.0, 1.0)), f - float2(1.0, 1.0)), u.x), u.y);
            }

            float Fbm(float2 texcoord)
            {
                float2 tc = texcoord * float2(.05, .05);
                float time = _Time.y * 0.5;
                float noise
                    = Noise((tc + time) * 1.0)
                    + Noise((tc + time) * 2.0) * 0.5
                    + Noise((tc + time) * 4.0) * 0.25;
                noise = noise / (1.0 + 0.5 + 0.25);

                return noise;
            }

            float2 frag (v2f_customrendertexture i) : SV_target
            {
                return float2(
                    Fbm(i.localTexcoord),
                    Fbm(i.localTexcoord + float2(1000.0, 1000.0)));
            }
            ENDCG
        }
    }
}
