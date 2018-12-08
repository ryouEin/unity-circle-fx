Shader "Custom/CircleFX"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderMode" = "Transparent"
        }
        Blend SrcAlpha One
        ZWrite Off

        Pass
        {
            CGPROGRAM

            /**************************************
            pragma宣言
            ***************************************/
            #pragma vertex vert
            #pragma fragment frag


            /**************************************
            include
            ***************************************/
            #include "UnityCG.cginc"


            /**************************************
            Propertiesで宣言した変数を使用するための宣言
            ***************************************/
            fixed4 _Color;


            /**************************************
            構造体定義
            ***************************************/
            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            /**************************************
            シェーダ処理
            ***************************************/
            // 頂点シェーダー
            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                return o;
            }

            // 補助関数群
            bool isInDonut(float distanceFromCenter, float insideDiameter, float outsideDiameter)
            {
                return distanceFromCenter >= insideDiameter && distanceFromCenter <= outsideDiameter;
            }

            bool isInFan(float radian, float fanEndRadian)
            {
                return radian <= fanEndRadian;
            }

            bool isInLackedDonut(float2 targetCoord, float insideDiameter, float outsideDiameter, float fanEndRadian)
            {
                const float PI = 3.14159;

                float distanceFromCenter = distance(float2(0, 0), targetCoord);
                float radian = atan2(targetCoord.y, targetCoord.x) + PI;

                return isInDonut(distanceFromCenter, insideDiameter, outsideDiameter) && isInFan(radian, fanEndRadian);
            }

            fixed3 calcAnimatingLackedDonutColor(
                float2 coord, fixed4 donutColor, float insideDiameter, float outsideDiameter,
                float rotateSpeed, float length, float lengthChange, float lengthChangeSpeed
            ) {
                    float rt = _Time.z * rotateSpeed;
                    float2x2 rotateMatrix = float2x2(cos(rt), -sin(rt), sin(rt), cos(rt));
                    float2 targetCoord = mul(rotateMatrix, coord);

                    float fanEndRadian = length + lengthChange * sin(_Time.z * lengthChangeSpeed);
                    if (isInLackedDonut(targetCoord, insideDiameter, outsideDiameter, fanEndRadian)) return donutColor.rgb * donutColor.a;

                    return fixed3(0, 0, 0);
            }

            // フラグメントシェーダー
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = fixed4(0, 0, 0, 1);
                float2 coord = i.uv - 0.5;

                color.rgb += calcAnimatingLackedDonutColor(coord, _Color, 0.45, 0.5, 0.79, 2.0, 1.0, 0.42);
                color.rgb += calcAnimatingLackedDonutColor(coord, _Color, 0.4, 0.5, -1.0, 3.14, 1.5, 0.79);
                color.rgb += calcAnimatingLackedDonutColor(coord, _Color, 0.3, 0.45, 1.27, 4.0, 1.3, 0.8);
                color.rgb += calcAnimatingLackedDonutColor(coord, _Color, 0.25, 0.35, 1.9, 2.0, 1.0, 1.48);
                color.rgb += calcAnimatingLackedDonutColor(coord, _Color, 0.225, 0.275, -1.2, 2.5, 2.5, 0.4);
                color.rgb += calcAnimatingLackedDonutColor(coord, _Color, 0.445, 0.455, 1.51, 4.0, 1.0, 1.0);
                color.rgb += calcAnimatingLackedDonutColor(coord, _Color, 0.395, 0.405, 1.0, 3.0, 1.0, 1.0);

                return color;
            }
            ENDCG
        }
    }
}