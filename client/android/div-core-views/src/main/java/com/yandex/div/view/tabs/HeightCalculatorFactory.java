package com.yandex.div.view.tabs;

import android.view.ViewGroup;
import androidx.annotation.NonNull;

public interface HeightCalculatorFactory {
    ViewPagerFixedSizeLayout.HeightCalculator getCardHeightCalculator(@NonNull ViewGroup channelGroup,
                                                                      @NonNull MeasureTabHeightFn measureTabHeights,
                                                                      @NonNull GetTabCountFn getTabCountFn);

    interface MeasureTabHeightFn {
        int apply(@NonNull ViewGroup channelGroup, int width, int tab);
    }

    interface GetTabCountFn {
        int apply();
    }
}
