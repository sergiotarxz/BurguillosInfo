export interface Ad {
    img: string,
    text: string
    href: string
    seconds: number
}
export default class CarouselAd {
    private currentAdNumber: number | null = null 
    private ad: Ad | null = null
    private timeoutNumber: number | null = null
    private firstAd = true
    private getCarousel(): HTMLElement {
        const carousel = document.querySelector('.carousel');
        if (carousel === null || !(carousel instanceof HTMLElement)) {
            this.noMoreAds()
            CarouselAd.fail('No carousel.')
        }
        return carousel
    }
    static fail(error: string): never {
        throw new Error(error)
    }

    public async run(): Promise<void> {
        this.loadOneAd()
        try {
            let start = 0
            let end = 0
            this.getCarousel().addEventListener('pointerdown', (event: MouseEvent) => {
                start = event.pageX
                console.log(start)
            })
            this.getCarousel().addEventListener('pointerup', (event: MouseEvent) => {
                end = event.pageX
                console.log(end)
                if (start - end > 100) {
                    if (this.timeoutNumber !== null) {
                        window.clearTimeout(this.timeoutNumber)
                    }
                    this.loadOneAd()
                } else {
                    const a = this.retrieveLinkCarousel()
                    if (a !== null) {
                        window.location.href = a.href
                    }
                }
            })

        } catch (e) {
            console.log(e)
            return
        }
    }

    private noMoreAds() {
        const carousel = this.getCarousel()
        if (carousel !== null) {
            carousel.remove();
        }
        this.expandPageContents();
        if (this.timeoutNumber === null) {
            return
        }
        window.clearTimeout(this.timeoutNumber)
    }

    private expandPageContents() {
        const pageContents = document.querySelector('div.page-contents'); 
        if (pageContents === null) {
            return;
        }
        pageContents.classList.add('no-carousel');
    }

    private retrieveLinkCarousel(): HTMLAnchorElement | null{
        const carousel = this.getCarousel()
        const a = carousel.querySelector('a')
        if (a === null) {
            return null 
        }
        return a
    }

    private async loadOneAd() {
        try {        
            const params = new URLSearchParams();
            if (this.currentAdNumber !== null) {
                params.append('n', ""+this.currentAdNumber);
            }
            const response = await fetch('/next-ad.json?' + params)
            const responseJson = await response.json()
            this.currentAdNumber = responseJson.current_ad_number
            this.ad = responseJson.ad
            if (this.ad === null) {
                this.noMoreAds()
                return
            }
            const must_continue = responseJson.continue
            const carousel = this.getCarousel()
            if (must_continue === 0
                    || carousel.offsetWidth === 0) {
                this.noMoreAds();
                return;
            }
            const aPrev = this.retrieveLinkCarousel()
            const allAnchors = carousel.querySelectorAll('a')
            const a = document.createElement('a')
            a.addEventListener('click', (event: MouseEvent) => {
                event.preventDefault()
            })
            a.addEventListener('pointerdown', (event: MouseEvent) => {
                event.preventDefault()
            })
            a.addEventListener('pointerup', (event: MouseEvent) => {
                event.preventDefault()
            })

            const image = document.createElement('img')
            const text_container = document.createElement('div')
            const text = document.createElement('h4')
            const promoted = document.createElement('p')

            promoted.classList.add('promoted-tag')
            promoted.innerText = "Promocionado"
            image.src = this.ad.img
            image.alt = ""
            text.innerText = this.ad.text
            a.href = this.ad.href

            a.append(image)
            text_container.append(promoted)
            text_container.append(text)
            a.append(text_container)
            if (this.firstAd) {
                carousel.innerHTML = ''
                this.firstAd = false
            }
            carousel.append(a)
            window.setTimeout(() => {
                a.classList.add('show')
                if (aPrev !== null) {
                    aPrev.classList.remove('show')
                    aPrev.classList.add('remove')
                    window.setTimeout(() => {
                        aPrev.remove()
                        for (const a of allAnchors) {
                            a.remove()
                        }
                    }, 1000)
                }
            }, 10)
            this.timeoutNumber = window.setTimeout(() => {
                this.loadOneAd()
            }, this.ad.seconds * 1000)
        } catch (e) {
            console.error(e)
            this.timeoutNumber = window.setTimeout(() => {
                this.loadOneAd()
            }, 1000)
        }

    }
}
