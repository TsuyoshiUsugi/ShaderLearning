//グリッチとはテレビや電⼦機器の不具合から⽣じる映像の乱れのこと

Shader "Unlit/Glitch"
{
    Properties
    {
        [NoScaleOffSet]_MainTex ("Texture", 2D) = "white" {}
        _FrameRate ("FrameRate", Range(0.1,30)) = 15
        _Frequency ("Frequency", Range(0,1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Tranparent" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _FrameRate;
            float _Frequency;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float random(float2 seeds)
            {
                //dotは内積を返す
                //float2(12.9898, 78.233)は乱数の種
                //sinはサインを返す
                //fracは小数点以下を返す
                return frac(sin(dot(seeds, float2(12.9898, 78.233))) * 43758.5453);
            }

            //パーリンノイズ
            //パーリンノイズは入力値のX、Yの変化に合わせて徐々に変化する乱数
            float perlinNoise(fixed2 st)
            {
                //floorは小数点以下を切り捨てる。つまり整数部分だけを返す
                fixed2 p = floor(st);
                //fracは小数点以下を返す。つまり小数部分だけを返す
                fixed2 f = frac(st);
                //ここで行っているのは、入力値のX、Yの変化に合わせて徐々に変化する乱数を生成している
                fixed2 u = f * f * (3.0 - 2.0 * f);

                float v00 = random(p + fixed2(0, 0));
                float v10 = random(p + fixed2(1, 0));
                float v01 = random(p + fixed2(0, 1));
                float v11 = random(p + fixed2(1, 1));

                return lerp(lerp(dot(v00, f - fixed2(0, 0)), dot(v10, f - fixed2(1, 0)), u.x),
                            lerp(dot(v01, f - fixed2(0, 1)), dot(v11, f - fixed2(1, 1)), u.x),
                            u.y) + 0.5f;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                //ポスタライズ。ポスタライズとは、任意の値に基づいて入力値を丸める処理。Sin関数のように一定間隔で同じ数字を返すようになる
                float posterize1 = floor(frac(perlinNoise(_SinTime) * 10) / (1 / _FrameRate)) * (1 / _FrameRate);
                float posterize2 = floor(frac(perlinNoise(_SinTime) * 5) / (1 / _FrameRate)) * (1 / _FrameRate);
                //uv.x方向のノイズ計算 -0.1 < noiseX < 0.1
                float noiseX = (2.0 * random(posterize1) - 0.5) * 0.1;
                //step(t,x) はxがtより大きい場合1を返す
                float frequency = step(random(posterize2), _Frequency);
                noiseX *= frequency;
                //uv.y方向のノイズ計算 -1 < noiseY < 1
                float noiseY = 2.0 * random(posterize1) - 0.5;
                //グリッチの高さの補間値計算 どの高さに出現するかは時間変化でランダム
                float glitchLine1 = step(uv.y - noiseY, random(noiseY));
                float glitchLine2 = step(uv.y + noiseY, noiseY);
                float glitch = saturate(glitchLine1 - glitchLine2);
                //速度調整
                uv.x = lerp(uv.x, uv.x + noiseX, glitch);
                //テクスチャサンプリング
                float4 glitchColor = tex2D(_MainTex, uv);
                return glitchColor;
            }
            ENDCG
        }
    }
}
