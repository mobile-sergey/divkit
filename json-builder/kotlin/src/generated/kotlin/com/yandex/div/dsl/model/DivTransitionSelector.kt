// Generated code. Do not modify.

package com.yandex.div.dsl.model

import java.net.URI
import com.fasterxml.jackson.annotation.*
import com.yandex.div.dsl.*
import com.yandex.div.dsl.context.*
import com.yandex.div.dsl.type.*
import com.yandex.div.dsl.util.*

enum class DivTransitionSelector(@JsonValue val value: String) {
    NONE("none"),
    DATA_CHANGE("data_change"),
    STATE_CHANGE("state_change"),
    ANY_CHANGE("any_change"),
}
