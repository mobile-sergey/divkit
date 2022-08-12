package com.yandex.div.core.animation

/**
 * Spring with parameters: dampingRatio = 1, duration = 0.5s velocity = 0, mass = 1
 * Tail, where values are bigger than 0.985 is cut, and rest is normalized to 1/0.985.
 * So effective duration of this animation is 0.3s.
 */
class SpringInterpolator : LookupTableInterpolator(VALUES) {
    private companion object {
        private val VALUES = floatArrayOf(
            0.0000f, 0.0005f, 0.0020f, 0.0045f, 0.0078f, 0.0119f, 0.0168f,
            0.0224f, 0.0286f, 0.0355f, 0.0429f, 0.0508f, 0.0592f, 0.0681f,
            0.0774f, 0.0870f, 0.0969f, 0.1072f, 0.1177f, 0.1285f, 0.1395f,
            0.1507f, 0.1621f, 0.1736f, 0.1853f, 0.1970f, 0.2089f, 0.2208f,
            0.2328f, 0.2448f, 0.2569f, 0.2689f, 0.2810f, 0.2930f, 0.3050f,
            0.3170f, 0.3289f, 0.3408f, 0.3526f, 0.3644f, 0.3760f, 0.3876f,
            0.3991f, 0.4105f, 0.4218f, 0.4330f, 0.4440f, 0.4550f, 0.4658f,
            0.4765f, 0.4871f, 0.4975f, 0.5078f, 0.5180f, 0.5280f, 0.5379f,
            0.5477f, 0.5573f, 0.5668f, 0.5761f, 0.5853f, 0.5944f, 0.6033f,
            0.6120f, 0.6206f, 0.6291f, 0.6374f, 0.6456f, 0.6537f, 0.6616f,
            0.6693f, 0.6770f, 0.6845f, 0.6918f, 0.6990f, 0.7061f, 0.7130f,
            0.7199f, 0.7265f, 0.7331f, 0.7395f, 0.7458f, 0.7520f, 0.7580f,
            0.7640f, 0.7698f, 0.7755f, 0.7810f, 0.7865f, 0.7918f, 0.7971f,
            0.8022f, 0.8072f, 0.8121f, 0.8169f, 0.8216f, 0.8262f, 0.8307f,
            0.8351f, 0.8394f, 0.8436f, 0.8477f, 0.8517f, 0.8557f, 0.8595f,
            0.8633f, 0.8669f, 0.8705f, 0.8740f, 0.8775f, 0.8808f, 0.8841f,
            0.8873f, 0.8904f, 0.8934f, 0.8964f, 0.8993f, 0.9022f, 0.9049f,
            0.9076f, 0.9103f, 0.9129f, 0.9154f, 0.9178f, 0.9202f, 0.9226f,
            0.9249f, 0.9271f, 0.9293f, 0.9314f, 0.9335f, 0.9355f, 0.9375f,
            0.9394f, 0.9413f, 0.9431f, 0.9449f, 0.9466f, 0.9483f, 0.9500f,
            0.9516f, 0.9532f, 0.9547f, 0.9562f, 0.9576f, 0.9591f, 0.9605f,
            0.9618f, 0.9631f, 0.9644f, 0.9657f, 0.9669f, 0.9681f, 0.9692f,
            0.9703f, 0.9714f, 0.9725f, 0.9736f, 0.9746f, 0.9756f, 0.9765f,
            0.9775f, 0.9784f, 0.9793f, 0.9802f, 0.9810f, 0.9818f, 0.9826f,
            0.9834f, 0.9842f, 0.9849f, 0.9856f, 0.9863f, 0.9870f, 0.9877f,
            0.9883f, 0.9890f, 0.9896f, 0.9902f, 0.9908f, 0.9913f, 0.9919f,
            0.9924f, 0.9930f, 0.9935f, 0.9940f, 0.9944f, 0.9949f, 0.9954f,
            0.9958f, 0.9963f, 0.9967f, 0.9971f, 0.9975f, 0.9979f, 0.9983f,
            0.9986f, 0.9990f, 0.9993f, 0.9997f, 1.0000f
        )
    }
}
