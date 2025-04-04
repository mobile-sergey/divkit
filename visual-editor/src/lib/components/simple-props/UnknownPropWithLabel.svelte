<script lang="ts" context="module">
    const PER_THEME_RE = /@\{theme\s*==\s*'dark'\s*\?\s*'(.*)'\s*:\s*'(.*)'}/;
</script>

<script lang="ts">
    import { createEventDispatcher, getContext } from 'svelte';
    import UnknownProp from './UnknownProp.svelte';
    import { LANGUAGE_CTX, type LanguageContext } from '../../ctx/languageContext';
    import type { ComponentProperty, SiblingComponentProperty } from '../../data/componentProps';
    import Switcher from '../controls/Switcher.svelte';
    import { tankerKeyToVariableName } from '../../utils/tanker';
    import { APP_CTX, type AppContext } from '../../ctx/appContext';
    import { encodeBackground } from '../../utils/encodeBackground';
    import { encodeDivString } from '../../utils/encodeDivString';
    import { isPaletteColor } from '../../data/palette';
    import sourceIcon from '../../../assets/source.svg?raw';
    import ExpressionValue from './ExpressionValue.svelte';
    import lightThemeIcon from '../../../assets/lightTheme.svg?url';
    import darkThemeIcon from '../../../assets/darkTheme.svg?url';

    export let item: ComponentProperty | SiblingComponentProperty;
    export let value: unknown;
    export let evalValue: unknown = undefined;
    export let processedJson: unknown = undefined;
    export let parentProcessedJson: unknown = undefined;
    export let parentEvalJson: unknown = undefined;

    const dispatch = createEventDispatcher();

    const { l10n, l10nString } = getContext<LanguageContext>(LANGUAGE_CTX);
    const { cardLocales, state, perThemeProps, expression2Dialog } = getContext<AppContext>(APP_CTX);
    const { tanker, locale, readOnly } = state;

    let lightValue: unknown = '';
    let darkValue: unknown = '';

    $: tankerToggled = typeof value === 'string' && value.startsWith('@{tanker_');
    $: perThemeToggled = typeof value === 'string' && PER_THEME_RE.test(value);
    $: isExpression = !tankerToggled && value !== evalValue && typeof value !== 'object';
    $: isPalette = !tankerToggled && item.type === 'color' && isPaletteColor(String(value));
    $: showSources = !tankerToggled && ('enableSources' in item && item.enableSources || isExpression);

    $: if (value !== undefined && perThemeToggled) {
        const match = PER_THEME_RE.exec(String(value));
        if (match) {
            lightValue = match[2];
            darkValue = match[1];
        }
    }

    $: isLabel = !showSources && !(
        item.type === 'text-styles' ||
        item.type === 'text-align' ||
        item.type === 'radio' ||
        item.type === 'background2' ||
        item.type === 'actions2' ||
        item.type === 'string' && item.enableTanker ||
        item.type === 'video_sources' ||
        item.type === 'alignment' ||
        item.type === 'margins-paddings' ||
        item.type === 'select-options'
    );

    $: hasLabel = 'name' in item && item.name || 'rawName' in item && item.rawName;

    let sourcesButton: HTMLButtonElement;

    function updatePerThemeValue(): void {
        value = `@{theme == 'dark' ? '${encodeDivString(String(darkValue))}' : '${encodeDivString(String(lightValue))}'}`;
        dispatch('change', {
            value,
            item
        });
    }

    function onPerThemeChange(): void {
        if (perThemeToggled) {
            lightValue = darkValue = value || '';
            updatePerThemeValue();
        } else {
            value = lightValue;
            dispatch('change', {
                value,
                item
            });
        }
    }

    function onThemeValueChange(event: CustomEvent<{
        value: unknown;
        item: ComponentProperty | SiblingComponentProperty;
    } | {
        values: {
            prop: string;
            value: unknown;
        }[];
        item: ComponentProperty | SiblingComponentProperty;
    }>, theme: 'light' | 'dark'): void {
        if (!('value' in event.detail)) {
            // Not supported
            return;
        }

        const newValue = event.detail.value;
        if (theme === 'light') {
            lightValue = newValue;
        } else {
            darkValue = newValue;
        }
        updatePerThemeValue();
    }

    function onTankerChange(): void {
        if (tankerToggled) {
            // todo do not lose value on multiple toggles
            dispatch('change', {
                values: [{
                    prop: 'text',
                    value: `@{${tankerKeyToVariableName('')}}`
                }, {
                    prop: 'ranges',
                    value: undefined
                }, {
                    prop: 'images',
                    value: undefined
                }],
                item
            });
        } else {
            const key = typeof value === 'string' ? state.getTankerKey(value) : '';
            const meta = key && $tanker[key] || undefined;
            const text = meta?.[$locale] || 'text';

            dispatch('change', {
                value: text,
                item
            });
        }
    }

    function onSourceClick(): void {
        expression2Dialog().show({
            target: sourcesButton,
            // eslint-disable-next-line no-nested-ternary
            value: typeof value === 'string' ?
                value :
                (typeof value === 'number' ? String(value) : ''),
            disabled: $readOnly,
            callback(val) {
                dispatch('change', {
                    value: val,
                    item
                });
            }
        });
    }
</script>

<svelte:element
    this={
        isLabel ?
            'label' :
            'div'
    }
    class="unknown-prop"
>
    {#if 'name' in item && item.name || 'rawName' in item && item.rawName}
        <div class="unknown-prop__name">
            <div class="unknown-prop__label">
                {#if 'rawName' in item}
                    {item.rawName}
                {:else if item.name}
                    {$l10n(item.name)}
                {/if}

                {#if showSources}
                    <button
                        bind:this={sourcesButton}
                        class="unknown-prop__source"
                        class:unknown-prop__source_toggle={isExpression}
                        on:click={onSourceClick}
                    >
                        <!-- eslint-disable-next-line svelte/no-at-html-tags -->
                        {@html sourceIcon}
                    </button>
                {/if}
            </div>

            {#if perThemeProps && item.enablePerTheme}
                <!-- svelte-ignore a11y-label-has-associated-control -->
                <label
                    class="unknown-prop__tanker"
                >
                    {$l10n('perThemeProps')}

                    <Switcher
                        bind:checked={perThemeToggled}
                        disabled={$readOnly}
                        on:change={onPerThemeChange}
                    />
                </label>
            {:else if 'enableTanker' in item && item.enableTanker && cardLocales.length}
                <svelte:element
                    this={(item.type === 'string' && item.enableTanker) ? 'label' : 'div'}
                    class="unknown-prop__tanker"
                >
                    {$l10n('tankerTitle')}

                    <Switcher
                        bind:checked={tankerToggled}
                        disabled={$readOnly}
                        on:change={onTankerChange}
                    />
                </svelte:element>
            {/if}
        </div>
    {/if}

    {#if perThemeToggled}
        <div class="unknown-prop__theme-row">
            <div
                class="unknown-prop__theme-image"
                title={$l10nString('lightTheme')}
                aria-label={$l10nString('lightTheme')}
                role="img"
                style:background-image="url({encodeBackground(lightThemeIcon)})"
            ></div>
            <UnknownProp
                {item}
                value={lightValue}
                {processedJson}
                {parentProcessedJson}
                {parentEvalJson}
                {tankerToggled}
                on:change={event => onThemeValueChange(event, 'light')}
            />
        </div>
        <div class="unknown-prop__theme-row">
            <div
                class="unknown-prop__theme-image"
                title={$l10nString('darkTheme')}
                aria-label={$l10nString('darkTheme')}
                role="img"
                style:background-image="url({encodeBackground(darkThemeIcon)})"
            ></div>
            <UnknownProp
                {item}
                value={darkValue}
                {processedJson}
                {parentProcessedJson}
                {parentEvalJson}
                {tankerToggled}
                on:change={event => onThemeValueChange(event, 'dark')}
            />
        </div>
    {:else if hasLabel && isExpression && !isPalette}
        <ExpressionValue
            {evalValue}
            on:click={onSourceClick}
        />
    {:else}
        <UnknownProp
            {item}
            {value}
            {processedJson}
            {parentProcessedJson}
            {parentEvalJson}
            {tankerToggled}
            on:change
        />
    {/if}
</svelte:element>

<style>
    .unknown-prop__name {
        display: flex;
        justify-content: space-between;
        margin-bottom: 6px;
        font-size: 14px;
        line-height: 20px;
        color: var(--text-secondary);
    }

    .unknown-prop__tanker {
        display: flex;
        gap: 8px;
        user-select: none;
    }

    .unknown-prop__label {
        display: flex;
        align-items: center;
    }

    .unknown-prop__source {
        width: 20px;
        height: 20px;
        margin: 0;
        margin-left: 4px;
        padding: 0;
        color: inherit;
        border: none;
        border-radius: 4px;
        background: none;
        cursor: pointer;
        opacity: 0;
        transition: .15s ease-in-out;
        transition-property: background-color, opacity;
    }

    .unknown-prop__source:focus,
    .unknown-prop:hover .unknown-prop__source {
        opacity: 1;
    }

    .unknown-prop__source_toggle {
        opacity: 1;
        color: var(--accent-purple);
    }

    .unknown-prop__source:hover {
        background-color: var(--fill-accent-2);
    }

    .unknown-prop__source :global(.source-icon) {
        transition: fill .15s ease-in-out;
    }

    .unknown-prop__source:focus-visible {
        outline: 1px solid var(--accent-purple);
    }

    .unknown-prop__theme-row {
        display: flex;
    }

    .unknown-prop__theme-row + .unknown-prop__theme-row {
        margin-top: 4px;
    }

    .unknown-prop__theme-row > :global(:last-child) {
        flex: 1 1 auto;
    }

    .unknown-prop__theme-image {
        flex: 0 0 auto;
        width: 20px;
        margin-right: 8px;
        background: no-repeat 50% 50%;
        background-size: 20px;
        filter: var(--icon-filter);
    }
</style>
